import SwiftUI

/// Mutable shared state holder for property inputs + cached valuations.
/// Seeded from SamplePortfolioData, allows adding new properties from the onboarding flow.
class PropertyRepository: ObservableObject {
    static let shared = PropertyRepository()

    private static let inputsKey = "savedPropertyInputs"
    private static let countKey = "savedAddedCount"
    private static let valuationsKey = "cachedValuations"
    private static let lastRefreshKey = "lastValuationRefresh"

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
            self.propertyInputs = SamplePortfolioData.propertyInputs
        }
        loadValuations()
    }

    // ─── Property CRUD ───────────────────────────────────────────────────────

    func addProperty(_ input: PropertyInput) {
        propertyInputs.insert(input, at: 0)
        addedCount += 1
        save()
    }

    func removeProperty(at index: Int) {
        guard propertyInputs.indices.contains(index) else { return }
        let removed = propertyInputs.remove(at: index)
        if index < addedCount { addedCount -= 1 }
        valuations.removeValue(forKey: removed.projectName)
        save()
        saveValuations()
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
    }

    // ─── Valuation refresh (calls 99acres valuation service) ─────────────────

    /// Wake the Render server to reduce cold-start latency on the batch request.
    @MainActor
    func wakeServer() async {
        await ValuationApi.wake()
    }

    /// Refresh valuations from the valuation service.
    /// - Parameter force: If true, skips both local staleness check and server-side cache.
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
            let response = try await ValuationApi.fetchBatchValuation(
                inputs: propertyInputs,
                forceRefresh: force
            )
            var newValuations: [String: CachedValuation] = [:]
            for v in response.valuations {
                newValuations[v.projectName] = CachedValuation(
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
            }
            valuations = newValuations
            lastValuationRefresh = Date()
            valuationState = .succeeded(at: Date())
            saveValuations()
            print("[ValuationRefresh] Updated \(newValuations.count) valuations")
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

    // ─── Persistence ─────────────────────────────────────────────────────────

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
