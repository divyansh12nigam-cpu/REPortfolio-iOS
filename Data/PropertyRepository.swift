import SwiftUI

/// Mutable shared state holder for property inputs + cached valuations.
/// Seeded from SamplePortfolioData, allows adding new properties from the onboarding flow.
///
/// Persistence strategy:
/// - UserDefaults = offline fallback (always written)
/// - Supabase = cloud source of truth (when authenticated)
class PropertyRepository: ObservableObject {
    static let shared = PropertyRepository()

    private static let inputsKey = "savedPropertyInputs"
    private static let countKey = "savedAddedCount"
    private static let valuationsKey = "cachedValuations"
    private static let lastRefreshKey = "lastValuationRefresh"
    private static let userIdKey = "savedUserId"

    @Published var propertyInputs: [PropertyInput]
    /// Number of user-added properties (inserted at the front of the list).
    @Published private(set) var addedCount: Int = 0

    // ─── Valuation cache (from 99acres valuation service) ────────────────────
    @Published var valuations: [String: CachedValuation] = [:]
    @Published var valuationState: ValuationState = .idle
    private(set) var lastValuationRefresh: Date? = nil

    /// Per-card refresh tracking — property names currently being refreshed via swipe.
    @Published var refreshingProperties: Set<String> = []
    /// Context for the most recent successful refresh (triggers toast in UI).
    @Published var lastRefreshContext: RefreshContext? = nil

    /// Valuations older than 7 days are considered stale.
    var isValuationStale: Bool {
        guard let last = lastValuationRefresh else { return true }
        return Date().timeIntervalSince(last) > 7 * 24 * 3600
    }

    /// Valuations older than 14 days trigger an "outdated" warning banner.
    var isValuationOutdated: Bool {
        guard let last = lastValuationRefresh else { return false }
        return Date().timeIntervalSince(last) > 14 * 24 * 3600
    }

    /// Oldest valuation fetchedAt date (for "Updated X days ago" display).
    var oldestValuationDate: Date? {
        valuations.values.map(\.fetchedAt).min()
    }

    /// Convenience — true while valuations are loading.
    var isRefreshingValuations: Bool {
        if case .loading = valuationState { return true }
        return false
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.inputsKey),
           let saved = try? JSONDecoder().decode([PropertyInput].self, from: data) {
            self.propertyInputs = saved
            self.addedCount = UserDefaults.standard.integer(forKey: Self.countKey)
        } else {
            self.propertyInputs = []
        }
        loadValuations()
    }

    // ─── Property CRUD ───────────────────────────────────────────────────────

    func addProperty(_ input: PropertyInput) {
        propertyInputs.insert(input, at: 0)
        addedCount += 1
        save()
        syncToCloud()
    }

    func removeProperty(at index: Int) {
        guard propertyInputs.indices.contains(index) else { return }
        let removed = propertyInputs.remove(at: index)
        if index < addedCount { addedCount -= 1 }
        valuations.removeValue(forKey: removed.projectName)
        save()
        saveValuations()
        syncToCloud()
    }

    func updateProperty(at index: Int, with input: PropertyInput) {
        guard propertyInputs.indices.contains(index) else { return }
        let oldName = propertyInputs[index].projectName
        propertyInputs[index] = input
        if oldName != input.projectName {
            if let v = valuations.removeValue(forKey: oldName) {
                valuations[input.projectName] = v
            }
        }
        save()
        saveValuations()
        syncToCloud()
    }

    // ─── Cloud sync ────────────────────────────────────────────────────────────

    /// Upload all local properties to Supabase (fire-and-forget).
    private func syncToCloud() {
        let inputs = propertyInputs  // capture outside Task
        Task { @MainActor in
            guard let userId = AuthManager.shared.currentUserId else { return }

            do {
                try await SupabasePropertyStore.replaceAll(
                    userId: userId,
                    inputs: inputs
                )
            } catch {
                print("[CloudSync] Upload failed (non-fatal): \(error.localizedDescription)")
            }
        }
    }

    /// Download properties from Supabase after sign-in.
    /// - Detects user switch → clears stale local data first.
    /// - If cloud has data → replaces local.
    /// - If cloud is empty but same user has local data → uploads local (migration).
    @MainActor
    func syncFromCloud() async {
        guard let userId = AuthManager.shared.currentUserId else { return }

        // Detect user switch — clear local data belonging to a different user
        let storedUserId = UserDefaults.standard.string(forKey: Self.userIdKey)
        if storedUserId != userId {
            propertyInputs = []
            addedCount = 0
            valuations = [:]
            lastValuationRefresh = nil
            save()
            saveValuations()
            UserDefaults.standard.set(userId, forKey: Self.userIdKey)
            print("[CloudSync] User changed (\(storedUserId ?? "none") → \(userId)) — cleared local data")
        }

        do {
            let cloudProperties = try await SupabasePropertyStore.fetchAll()

            if !cloudProperties.isEmpty {
                // Cloud has data — use it as source of truth
                propertyInputs = cloudProperties
                addedCount = cloudProperties.count  // all cloud properties are user-added
                save()
                print("[CloudSync] Downloaded \(cloudProperties.count) properties from cloud")
            } else if addedCount > 0 {
                // Cloud is empty but local has user-added data — migrate up
                try await SupabasePropertyStore.replaceAll(
                    userId: userId,
                    inputs: propertyInputs
                )
                print("[CloudSync] Migrated \(propertyInputs.count) local properties to cloud")
            } else {
                print("[CloudSync] No cloud data and no local user data — empty portfolio")
            }
        } catch {
            print("[CloudSync] Sync failed (using local data): \(error.localizedDescription)")
        }
    }

    // ─── Valuation refresh (cache-aware) ───────────────────────────────────────

    /// Wake the Render server to reduce cold-start latency on the batch request.
    @MainActor
    func wakeServer() async {
        await ValuationApi.wake()
    }

    /// Refresh valuations using cache-aware flow:
    /// 1. Check Supabase shared cache for hits
    /// 2. Scrape only cache misses via Render valuation service
    /// 3. Store fresh results in shared cache (benefits other users)
    /// - Parameter force: If true, skips local 7-day staleness check (but still uses Supabase + server caches).
    @MainActor
    func refreshValuations(force: Bool = false) async {
        // Skip if not stale (unless force refresh)
        if !force && !isValuationStale && !valuations.isEmpty {
            print("[ValuationRefresh] Skipping — valuations are fresh")
            return
        }

        print("[ValuationRefresh] Starting refresh for \(propertyInputs.count) properties (force: \(force))...")
        valuationState = .loading(startedAt: Date())

        do {
            var mergedValuations: [String: CachedValuation] = [:]
            var missedInputs = propertyInputs

            // Step 1: Always check Supabase shared cache (even on force refresh)
            do {
                let cacheHits = try await SupabaseValuationCache.batchLookup(inputs: propertyInputs)
                mergedValuations.merge(cacheHits) { _, new in new }
                missedInputs = SupabaseValuationCache.cacheMisses(inputs: propertyInputs, hits: cacheHits)
                print("[ValuationRefresh] Cache hits: \(cacheHits.count), misses: \(missedInputs.count)")
            } catch {
                print("[ValuationRefresh] Cache lookup failed (will scrape all): \(error.localizedDescription)")
                missedInputs = propertyInputs
            }

            // Step 2: Scrape only cache misses (let server use its 8-hour cache)
            if !missedInputs.isEmpty {
                let response = try await ValuationApi.fetchBatchValuation(
                    inputs: missedInputs,
                    forceRefresh: false
                )
                var freshValuations: [String: CachedValuation] = [:]
                for v in response.valuations {
                    let cached = CachedValuation(
                        valueLow: v.valueLow,
                        valueHigh: v.valueHigh,
                        fairValue: v.fairValue,
                        pricePerSqft: v.pricePerSqft,
                        growth: v.growth,
                        growthPercent: v.growthPercent,
                        source: v.source,
                        confidence: v.confidence,
                        comparableCount: v.comparableCount,
                        bhkFiltered: v.bhkFiltered ?? false,
                        sizeFiltered: v.sizeFiltered ?? false,
                        filterFallback: v.filterFallback ?? "none",
                        warnings: v.warnings ?? [],
                        fetchedAt: Date()
                    )
                    freshValuations[v.projectName] = cached
                    mergedValuations[v.projectName] = cached
                }

                // Step 3: Store fresh results in shared cache (benefits other users)
                Task {
                    await SupabaseValuationCache.storeResults(
                        inputs: missedInputs,
                        valuations: freshValuations
                    )
                }
            }

            valuations = mergedValuations
            lastValuationRefresh = Date()
            if force { lastRefreshContext = .allProperties }
            valuationState = .succeeded(at: Date())
            saveValuations()
            print("[ValuationRefresh] Updated \(mergedValuations.count) valuations")
        } catch let error as ValuationError {
            print("[ValuationRefresh] Failed: \(error.userMessage)")
            valuationState = .failed(error: error, at: Date())
        } catch {
            print("[ValuationRefresh] Failed: \(error)")
            valuationState = .failed(
                error: .networkError(error.localizedDescription),
                at: Date()
            )
        }
    }

    /// Refresh valuation for a single property (used after adding a property or swipe-to-refresh).
    /// Checks shared Supabase cache first (exact match or same-society fallback),
    /// only scrapes 99acres if no cached value is available.
    ///
    /// - Parameter forceRefresh: Skip cache and always scrape. Used by swipe-to-refresh.
    /// - Parameter cardRefresh: When true, shows "Calculating..." on that card instead of the global top banner.
    @MainActor
    func refreshSingleValuation(for input: PropertyInput, forceRefresh: Bool = false, cardRefresh: Bool = false) async {
        print("[ValuationRefresh] Refreshing single property: \(input.projectName) (force: \(forceRefresh), card: \(cardRefresh))")

        if cardRefresh {
            refreshingProperties.insert(input.projectName)
        } else {
            valuationState = .loading(startedAt: Date())
        }

        do {
            // Step 1: Check shared cache (exact match + society/BHK fallback)
            if !forceRefresh {
                if let cached = try? await SupabaseValuationCache.singleLookup(input: input) {
                    print("[ValuationRefresh] Cache hit for \(input.projectName) — skipping scrape")
                    valuations[input.projectName] = cached
                    lastValuationRefresh = Date()
                    if cardRefresh { refreshingProperties.remove(input.projectName) }
                    // No lastRefreshContext here — toast only for actual scrapes, not cache hits
                    valuationState = .succeeded(at: Date())
                    saveValuations()
                    return
                }
            }

            // Step 2: No cache hit — scrape via backend
            let response = try await ValuationApi.fetchBatchValuation(
                inputs: [input],
                forceRefresh: forceRefresh
            )
            var freshValuations: [String: CachedValuation] = [:]
            for v in response.valuations {
                let cached = CachedValuation(
                    valueLow: v.valueLow,
                    valueHigh: v.valueHigh,
                    fairValue: v.fairValue,
                    pricePerSqft: v.pricePerSqft,
                    growth: v.growth,
                    growthPercent: v.growthPercent,
                    source: v.source,
                    confidence: v.confidence,
                    comparableCount: v.comparableCount,
                    bhkFiltered: v.bhkFiltered ?? false,
                    sizeFiltered: v.sizeFiltered ?? false,
                    filterFallback: v.filterFallback ?? "none",
                    warnings: v.warnings ?? [],
                    fetchedAt: Date()
                )
                freshValuations[v.projectName] = cached
                valuations[v.projectName] = cached
            }

            // Store in shared cache (benefits other users + future BHK fallbacks)
            Task {
                await SupabaseValuationCache.storeResults(
                    inputs: [input],
                    valuations: freshValuations
                )
            }

            lastValuationRefresh = Date()
            if cardRefresh { refreshingProperties.remove(input.projectName) }
            lastRefreshContext = .singleProperty(name: input.projectName)
            valuationState = .succeeded(at: Date())
            saveValuations()
            print("[ValuationRefresh] Updated valuation for \(input.projectName)")
        } catch let error as ValuationError {
            print("[ValuationRefresh] Single refresh failed: \(error.userMessage)")
            if cardRefresh { refreshingProperties.remove(input.projectName) }
            valuationState = .failed(error: error, at: Date())
        } catch {
            print("[ValuationRefresh] Single refresh failed: \(error)")
            if cardRefresh { refreshingProperties.remove(input.projectName) }
            valuationState = .failed(
                error: .networkError(error.localizedDescription),
                at: Date()
            )
        }
    }

    // ─── Persistence (UserDefaults — offline fallback) ─────────────────────────

    private func save() {
        if let data = try? JSONEncoder().encode(propertyInputs) {
            UserDefaults.standard.set(data, forKey: Self.inputsKey)
        }
        UserDefaults.standard.set(addedCount, forKey: Self.countKey)
    }

    private func saveValuations() {
        if let data = try? JSONEncoder().encode(valuations) {
            UserDefaults.standard.set(data, forKey: Self.valuationsKey)
        }
        if let date = lastValuationRefresh {
            UserDefaults.standard.set(date, forKey: Self.lastRefreshKey)
        }
    }

    private func loadValuations() {
        if let data = UserDefaults.standard.data(forKey: Self.valuationsKey),
           let saved = try? JSONDecoder().decode([String: CachedValuation].self, from: data) {
            valuations = saved
        }
        lastValuationRefresh = UserDefaults.standard.object(forKey: Self.lastRefreshKey) as? Date
    }
}
