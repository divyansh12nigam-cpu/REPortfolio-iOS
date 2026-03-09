import Foundation
import Supabase

/// Shared valuation cache in Supabase — cross-user, 30-day TTL.
///
/// Cache key: `"society|city|locality|floorPlan"` (lowercased, pipe-delimited).
/// Stores `price_per_sqft`; client computes absolute values by multiplying by user's `areaSqft`.
enum SupabaseValuationCache {

    /// 30-day TTL for cached valuations.
    private static let cacheTTL: TimeInterval = 30 * 24 * 3600

    // MARK: - Cache key

    /// Build a deterministic cache key from property attributes.
    static func cacheKey(for input: PropertyInput) -> String {
        let society = input.societyName.trimmingCharacters(in: .whitespaces).lowercased()
        let city = input.city.lowercased()
        let locality = input.locality.lowercased()
        let fp = input.floorPlan?.rawValue.lowercased() ?? ""
        return "\(society)|\(city)|\(locality)|\(fp)"
    }

    // MARK: - Batch lookup

    /// Look up cached valuations for a list of properties.
    /// Returns a dictionary of `projectName → CachedValuation` for cache hits.
    /// Cache misses are omitted.
    static func batchLookup(inputs: [PropertyInput]) async throws -> [String: CachedValuation] {
        let keys = inputs.map { cacheKey(for: $0) }
        let uniqueKeys = Array(Set(keys))

        guard !uniqueKeys.isEmpty else { return [:] }

        let rows: [ValuationCacheRow] = try await SupabaseManager.client
            .from("valuation_cache")
            .select()
            .in("cache_key", values: uniqueKeys)
            .execute()
            .value

        // Build lookup by cache key
        let rowsByKey = Dictionary(uniqueKeysWithValues: rows.map { ($0.cacheKey, $0) })

        // Map back to property names, scaling by each property's area
        var result: [String: CachedValuation] = [:]
        for input in inputs {
            let key = cacheKey(for: input)
            guard let row = rowsByKey[key] else { continue }

            // Check TTL
            guard Date().timeIntervalSince(row.fetchedAt) < cacheTTL else {
                print("[ValuationCache] Expired: \(key) (fetched \(Int(Date().timeIntervalSince(row.fetchedAt) / 86400))d ago)")
                continue
            }

            // Scale price_per_sqft to this property's area
            let area = Double(max(input.areaSqft, 1000)) // fallback 1000 sqft if no area
            let fairValue = row.pricePerSqft * area
            let valueLow = fairValue * 0.95
            let valueHigh = fairValue * 1.05
            let growth = valueHigh - Double(input.purchasePrice)

            result[input.projectName] = CachedValuation(
                valueLow: valueLow,
                valueHigh: valueHigh,
                fairValue: fairValue,
                pricePerSqft: row.pricePerSqft,
                growth: growth,
                growthPercent: input.purchasePrice > 0
                    ? (growth / Double(input.purchasePrice)) * 100 : 0,
                source: row.source,
                confidence: row.confidence,
                comparableCount: row.comparableCount,
                bhkFiltered: row.bhkFiltered,
                sizeFiltered: row.sizeFiltered,
                filterFallback: row.filterFallback,
                warnings: row.warnings,
                fetchedAt: row.fetchedAt
            )
        }

        print("[ValuationCache] Cache hits: \(result.count)/\(inputs.count)")
        return result
    }

    // MARK: - Store results

    /// Store fresh valuation results in the shared cache.
    /// Uses upsert to update existing entries.
    static func storeResults(inputs: [PropertyInput], valuations: [String: CachedValuation]) async {
        var rows: [ValuationCacheInsert] = []

        for input in inputs {
            guard let v = valuations[input.projectName],
                  v.pricePerSqft > 0 else { continue }

            let key = cacheKey(for: input)
            rows.append(ValuationCacheInsert(
                cacheKey: key,
                societyName: input.societyName,
                city: input.city,
                locality: input.locality,
                floorPlan: input.floorPlan?.rawValue,
                pricePerSqft: v.pricePerSqft,
                valueLow: v.valueLow,
                valueHigh: v.valueHigh,
                fairValue: v.fairValue,
                source: v.source,
                confidence: v.confidence,
                comparableCount: v.comparableCount,
                bhkFiltered: v.bhkFiltered,
                sizeFiltered: v.sizeFiltered,
                filterFallback: v.filterFallback,
                warnings: v.warnings,
                fetchedAt: Date()
            ))
        }

        guard !rows.isEmpty else { return }

        do {
            try await SupabaseManager.client
                .from("valuation_cache")
                .upsert(rows, onConflict: "cache_key")
                .execute()
            print("[ValuationCache] Stored \(rows.count) cache entries")
        } catch {
            print("[ValuationCache] Store failed (non-fatal): \(error.localizedDescription)")
        }
    }

    // MARK: - Identify cache misses

    /// Return property inputs that are NOT in the provided cache hits.
    static func cacheMisses(inputs: [PropertyInput], hits: [String: CachedValuation]) -> [PropertyInput] {
        inputs.filter { hits[$0.projectName] == nil }
    }
}

// MARK: - Row DTOs

private struct ValuationCacheRow: Decodable {
    let id: String
    let cacheKey: String
    let societyName: String
    let city: String
    let locality: String
    let floorPlan: String?
    let pricePerSqft: Double
    let valueLow: Double
    let valueHigh: Double
    let fairValue: Double
    let source: String
    let confidence: String
    let comparableCount: Int
    let bhkFiltered: Bool
    let sizeFiltered: Bool
    let filterFallback: String
    let warnings: [String]
    let fetchedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case cacheKey = "cache_key"
        case societyName = "society_name"
        case city, locality
        case floorPlan = "floor_plan"
        case pricePerSqft = "price_per_sqft"
        case valueLow = "value_low"
        case valueHigh = "value_high"
        case fairValue = "fair_value"
        case source, confidence
        case comparableCount = "comparable_count"
        case bhkFiltered = "bhk_filtered"
        case sizeFiltered = "size_filtered"
        case filterFallback = "filter_fallback"
        case warnings
        case fetchedAt = "fetched_at"
    }
}

private struct ValuationCacheInsert: Encodable {
    let cacheKey: String
    let societyName: String
    let city: String
    let locality: String
    let floorPlan: String?
    let pricePerSqft: Double
    let valueLow: Double
    let valueHigh: Double
    let fairValue: Double
    let source: String
    let confidence: String
    let comparableCount: Int
    let bhkFiltered: Bool
    let sizeFiltered: Bool
    let filterFallback: String
    let warnings: [String]
    let fetchedAt: Date

    enum CodingKeys: String, CodingKey {
        case cacheKey = "cache_key"
        case societyName = "society_name"
        case city, locality
        case floorPlan = "floor_plan"
        case pricePerSqft = "price_per_sqft"
        case valueLow = "value_low"
        case valueHigh = "value_high"
        case fairValue = "fair_value"
        case source, confidence
        case comparableCount = "comparable_count"
        case bhkFiltered = "bhk_filtered"
        case sizeFiltered = "size_filtered"
        case filterFallback = "filter_fallback"
        case warnings
        case fetchedAt = "fetched_at"
    }
}
