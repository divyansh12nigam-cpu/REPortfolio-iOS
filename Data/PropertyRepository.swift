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
    /// - Parameter force: If true, skips local staleness check and server-side cache.
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

            // Step 1: Check Supabase shared cache (skip on force refresh)
            if !force {
                do {
                    let cacheHits = try await SupabaseValuationCache.batchLookup(inputs: propertyInputs)
                    mergedValuations.merge(cacheHits) { _, new in new }
                    missedInputs = SupabaseValuationCache.cacheMisses(inputs: propertyInputs, hits: cacheHits)
                    print("[ValuationRefresh] Cache hits: \(cacheHits.count), misses: \(missedInputs.count)")
                } catch {
                    print("[ValuationRefresh] Cache lookup failed (will scrape all): \(error.localizedDescription)")
                    missedInputs = propertyInputs
                }
            }

            // Step 2: Scrape only cache misses (or all if force)
            if !missedInputs.isEmpty {
                let response = try await ValuationApi.fetchBatchValuation(
                    inputs: missedInputs,
                    forceRefresh: force
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
