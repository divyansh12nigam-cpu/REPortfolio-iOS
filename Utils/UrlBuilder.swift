import Foundation

/// Builds 99acres URLs for insight card CTAs.
struct NinetyNineAcresURL {

    /// Search URL for properties similar to the given input.
    /// Format: https://www.99acres.com/property-for-rent-in-sector-62-noida-ffid
    static func search(for input: PropertyInput) -> URL? {
        // Determine rent vs sale — seed data has nil usageType,
        // so infer from monthlyRent > 0 as the fallback.
        let isRent: Bool
        if let usage = input.usageType {
            isRent = usage == .rentLease
        } else {
            isRent = input.monthlyRent > 0
        }
        let transactionType = isRent ? "rent" : "sale"

        // Normalise: lowercase, collapse spaces → hyphens
        let city = input.city
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
        let locality = input.locality
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")

        // 99acres SEO URL format: property-for-{rent|sale}-in-{locality}-{city}-ffid
        var urlString = "https://www.99acres.com/property-for-\(transactionType)-in-"
        if !locality.isEmpty {
            urlString += "\(locality)-"
        }
        urlString += "\(city)-ffid"

        return URL(string: urlString)
    }

    /// URL for the 99acres post-property listing form.
    static let postProperty = URL(string: "https://www.99acres.com/postproperty/")!
}
