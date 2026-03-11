import Foundation
import Supabase

/// Fetches locality → society mapping from the Supabase `project_directory` table.
/// Caches in memory for the app session; refreshes on next launch.
/// Falls back to hardcoded `LocationData` for cities not yet scraped or on fetch failure.
enum ProjectDirectoryService {

    // MARK: - In-memory cache

    /// city (lowercased) → sorted locality names
    private(set) static var localities: [String: [String]] = [:]
    /// "city|locality" (lowercased) → sorted society names
    private(set) static var societies: [String: [String]] = [:]
    /// "city|locality|society" (lowercased) → available FloorPlan options
    private(set) static var societyConfigurations: [String: [FloorPlan]] = [:]
    /// city (lowercased) → ALL society names across all localities (flat, sorted, deduplicated)
    private(set) static var allCitySocieties: [String: [String]] = [:]
    /// "city|society" (lowercased) → localities (original case) for reverse lookup
    /// A society may appear in multiple localities (e.g. "The Golden Palm" in Sector 153 & 168).
    private(set) static var societyLocality: [String: [String]] = [:]
    /// "city|society" (lowercased) → area sizes per floor plan label ("2 BHK" → [1050, 1225])
    private(set) static var societyAreaSizes: [String: [String: [Int]]] = [:]

    /// True after at least one successful fetch.
    private(set) static var isLoaded = false

    // MARK: - Load from Supabase

    /// Fetch the full project directory for a given city.
    /// Called once when AddPropertyStep1View appears or when the user selects a city.
    /// Safe to call multiple times — skips if already loaded for this city.
    static func loadDirectory(for city: String) async {
        let cityLower = city.lowercased()

        // Skip if already loaded for this city
        if localities[cityLower] != nil { return }

        do {
            let rows: [ProjectDirectoryRow] = try await SupabaseManager.client
                .from("project_directory")
                .select()
                .ilike("city", value: cityLower)
                .order("locality")
                .order("society_name")
                .execute()
                .value

            guard !rows.isEmpty else {
                print("[ProjectDirectory] No data for \(city) — will use hardcoded fallback")
                return
            }

            // Build locality list (unique, sorted)
            var localitySet = Set<String>()
            var societyMap: [String: [String]] = [:]
            var allSocietySet = Set<String>()

            for row in rows {
                localitySet.insert(row.locality)
                let key = "\(cityLower)|\(row.locality.lowercased())"
                societyMap[key, default: []].append(row.societyName)

                // Build city-wide society list + reverse lookup
                allSocietySet.insert(row.societyName)
                let reverseKey = "\(cityLower)|\(row.societyName.lowercased())"
                societyLocality[reverseKey, default: []].append(row.locality)

                // Parse BHK configurations if present
                if let configStr = row.configurations, !configStr.isEmpty {
                    let configKey = "\(cityLower)|\(row.locality.lowercased())|\(row.societyName.lowercased())"
                    let floorPlans = configStr
                        .split(separator: ",")
                        .compactMap { Int(String($0).trimmingCharacters(in: .whitespaces)) }
                        .compactMap { FloorPlan.fromBedroomCount($0) }
                    if !floorPlans.isEmpty {
                        societyConfigurations[configKey] = floorPlans
                    }
                }

                // Cache area sizes from Supabase (keyed by city|society)
                if let areas = row.areaSizes, !areas.isEmpty {
                    let areaKey = "\(cityLower)|\(row.societyName.lowercased())"
                    societyAreaSizes[areaKey] = areas
                }
            }

            // Store sorted
            localities[cityLower] = localitySet.sorted()
            for (key, names) in societyMap {
                // Deduplicate and sort
                societies[key] = Array(Set(names)).sorted()
            }
            allCitySocieties[cityLower] = allSocietySet.sorted()

            // Deduplicate locality arrays in reverse lookup (preserve insertion order)
            for (key, locs) in societyLocality {
                var seen = Set<String>()
                societyLocality[key] = locs.filter { seen.insert($0).inserted }
            }

            isLoaded = true
            print("[ProjectDirectory] Loaded \(localitySet.count) localities, \(rows.count) societies for \(city)")
        } catch {
            print("[ProjectDirectory] Fetch failed (will use hardcoded fallback): \(error.localizedDescription)")
        }
    }

    // MARK: - Query (with hardcoded fallback)

    /// Localities for a given city. Falls back to LocationData if not loaded.
    static func localitiesFor(_ city: String) -> [String] {
        let key = city.lowercased()
        if let dynamic = localities[key], !dynamic.isEmpty {
            return dynamic
        }
        return LocationData.localitiesFor(city)
    }

    /// Societies for a given locality in a given city. Falls back to LocationData.
    static func societiesFor(locality: String, city: String) -> [String] {
        let key = "\(city.lowercased())|\(locality.lowercased())"
        if let dynamic = societies[key], !dynamic.isEmpty {
            return dynamic
        }
        return LocationData.societiesFor(locality)
    }

    /// Floor plan options for a specific society. Returns nil if no data available
    /// (caller should fall back to FloorPlan.allCases).
    /// When locality is empty, searches across all localities for a match.
    static func configurationsFor(society: String, locality: String, city: String) -> [FloorPlan]? {
        let cityLower = city.lowercased()
        let societyLower = society.lowercased()

        if !locality.isEmpty {
            let key = "\(cityLower)|\(locality.lowercased())|\(societyLower)"
            if let configs = societyConfigurations[key] { return configs }
        }

        // Fallback: search across all localities for this society
        let suffix = "|\(societyLower)"
        for (key, configs) in societyConfigurations where key.hasPrefix(cityLower) && key.hasSuffix(suffix) {
            return configs
        }
        return nil
    }

    /// All societies for a city across all localities. Falls back to LocationData.
    static func allSocietiesFor(city: String) -> [String] {
        let key = city.lowercased()
        if let dynamic = allCitySocieties[key], !dynamic.isEmpty {
            return dynamic
        }
        return LocationData.allSocietiesFor(city)
    }

    /// Area sizes for a given society + floor plan. Checks Supabase cache first, falls back to hardcoded AreaData.
    static func areasFor(society: String, floorPlan: FloorPlan, city: String) -> [Int]? {
        let key = "\(city.lowercased())|\(society.lowercased())"
        if let areaMap = societyAreaSizes[key],
           let areas = areaMap[floorPlan.rawValue], !areas.isEmpty {
            return areas
        }
        return AreaData.areasFor(society: society, floorPlan: floorPlan)
    }

    /// Reverse lookup: locality for a given society in a city.
    /// When a society exists in multiple localities, returns the first one
    /// (user can override manually in the locality field).
    static func localityFor(society: String, city: String) -> String? {
        let key = "\(city.lowercased())|\(society.lowercased())"
        if let locs = societyLocality[key], let first = locs.first {
            return first
        }
        return LocationData.localityFor(society: society, city: city)
    }

    // MARK: - Reset (for testing)

    /// Clear the in-memory cache, forcing a re-fetch on next loadDirectory call.
    static func reset() {
        localities = [:]
        societies = [:]
        societyConfigurations = [:]
        allCitySocieties = [:]
        societyLocality = [:]
        societyAreaSizes = [:]
        isLoaded = false
    }
}

// MARK: - Row DTO

private struct ProjectDirectoryRow: Decodable {
    let city: String
    let locality: String
    let societyName: String
    let configurations: String?
    let areaSizes: [String: [Int]]?

    enum CodingKeys: String, CodingKey {
        case city, locality, configurations
        case societyName = "society_name"
        case areaSizes = "area_sizes"
    }
}
