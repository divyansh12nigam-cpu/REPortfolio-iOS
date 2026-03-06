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
    @Published var isRefreshingValuations: Bool = false
    private(set) var lastValuationRefresh: Date? = nil

    /// Valuations older than 7 days are considered stale.
    var isValuationStale: Bool {
        guard let last = lastValuationRefresh else { return true }
        return Date().timeIntervalSince(last) > 7 * 24 * 3600
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
        // Remove cached valuation for the deleted property
        valuations.removeValue(forKey: removed.projectName)
        save()
        saveValuations()
    }

    func updateProperty(at index: Int, with input: PropertyInput) {
        guard propertyInputs.indices.contains(index) else { return }
        let oldName = propertyInputs[index].projectName
        propertyInputs[index] = input
        // If property name changed, migrate cached valuation
        if oldName != input.projectName {
            if let v = valuations.removeValue(forKey: oldName) {
                valuations[input.projectName] = v
            }
        }
        save()
        saveValuations()
    }

    // ─── Valuation refresh (calls 99acres valuation service) ─────────────────

    @MainActor
    func refreshValuations() async {
        print("[ValuationRefresh] 🚀 Starting refresh for \(propertyInputs.count) properties...")
        print("[ValuationRefresh] First property: \(propertyInputs.first?.projectName ?? "none")")
        isRefreshingValuations = true
        defer { isRefreshingValuations = false }

        do {
            print("[ValuationRefresh] Calling ValuationApi.fetchBatchValuation...")
            let response = try await ValuationApi.fetchBatchValuation(inputs: propertyInputs)
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
                    fetchedAt: Date()
                )
            }
            valuations = newValuations
            lastValuationRefresh = Date()
            saveValuations()
            print("[ValuationRefresh] Updated \(newValuations.count) valuations")
        } catch {
            print("[ValuationRefresh] ❌ Failed: \(error)")
            if let urlError = error as? URLError {
                print("[ValuationRefresh] URLError code: \(urlError.code.rawValue) — \(urlError.localizedDescription)")
            }
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
