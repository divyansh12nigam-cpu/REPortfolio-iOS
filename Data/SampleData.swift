import Foundation

// ─── Property inputs (mirrors SamplePortfolioData.kt) ────────────────────────

struct PropertyInput {
    let projectName: String
    let city: String
    let locality: String
    let areaSqft: Int
    let purchasePrice: Int64
    let purchaseYear: Int
    let monthlyRent: Int
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

enum SamplePortfolioData {

    // Source-of-truth inputs (mirrors SamplePortfolioData.propertyInputs)
    static let propertyInputs: [PropertyInput] = [
        PropertyInput(projectName: "Factory in Ghaziabad",    city: "Ghaziabad", locality: "Industrial Area", areaSqft: 5000, purchasePrice: 14_000_000, purchaseYear: 2015, monthlyRent: 21_000),
        PropertyInput(projectName: "Office in Noida Sector 62", city: "Noida",    locality: "Sector 62",      areaSqft: 1800, purchasePrice:  9_000_000, purchaseYear: 2018, monthlyRent: 45_000),
        PropertyInput(projectName: "Old Home in Vasundhra",   city: "Noida",     locality: "Vasundhra",      areaSqft: 1200, purchasePrice:  5_000_000, purchaseYear: 2012, monthlyRent: 30_000),
        PropertyInput(projectName: "Flat in DLF Phase 5",     city: "Gurugram",  locality: "DLF Phase 5",    areaSqft: 1200, purchasePrice:  8_500_000, purchaseYear: 2020, monthlyRent: 55_000),
        PropertyInput(projectName: "Shop in Lajpat Nagar",    city: "Delhi",     locality: "Lajpat Nagar",   areaSqft:  400, purchasePrice:  6_000_000, purchaseYear: 2017, monthlyRent: 30_000),
    ]

    // City base price per sqft (mirrors backend scrapingService.js)
    private static let cityBasePrice: [String: Int] = [
        "Ghaziabad": 3_800, "Noida": 5_500, "Gurugram": 7_200,
        "Delhi": 9_000, "Mumbai": 18_000, "Pune": 7_500,
        "Bengaluru": 6_800, "Hyderabad": 5_800, "Chennai": 6_200, "Kolkata": 4_500,
    ]
    private static let defaultBasePrice = 5_000

    // Card variant cycle pattern
    private static let variantPattern: [PropertyCardVariant] = [
        .plain, .insight, .addPurchasePrice, .insightAction, .plain,
    ]

    // ─── Computed valuations ──────────────────────────────────────────────────

    private struct Valuation {
        let input: PropertyInput
        let fairValue: Double
        let lowValue: Double
        let highValue: Double
        let growth: Double
    }

    private static func valuations(for inputs: [PropertyInput]) -> [Valuation] {
        inputs.map { p in
            let pricePerSqft = Double(cityBasePrice[p.city] ?? defaultBasePrice)
            let fair  = pricePerSqft * Double(p.areaSqft)
            let low   = fair * 0.95
            let high  = fair * 1.05
            let growth = high - Double(p.purchasePrice)
            return Valuation(input: p, fairValue: fair, lowValue: low, highValue: high, growth: growth)
        }
    }

    private static var valuations: [Valuation] { valuations(for: propertyInputs) }

    // ─── Properties list ──────────────────────────────────────────────────────

    static func properties(for inputs: [PropertyInput]) -> [PortfolioProperty] {
        valuations(for: inputs).enumerated().map { i, v in
            let variant = i < variantPattern.count ? variantPattern[i] : .plain
            let insightText: String
            switch variant {
            case .insight:
                insightText = "Similar properties are getting upto ₹\(Int((Double(v.input.monthlyRent) * 1.4 / 1000).rounded()))k monthly rent"
            case .insightAction:
                insightText = "20+ tenants are looking to rent similar property in the area"
            default:
                insightText = ""
            }
            return PortfolioProperty(
                title: v.input.projectName,
                status: v.input.monthlyRent > 0 ? "On Rent" : "Self Use",
                estValue: Formatters.formatValueRange(low: v.lowValue, high: v.highValue),
                estGrowth: Formatters.formatAmount(v.growth),
                monthlyRental: Formatters.formatRent(Double(v.input.monthlyRent)),
                cardVariant: variant,
                insightText: insightText,
                actionLabel: variant == .insightAction ? "Post now" : ""
            )
        }
    }

    static var properties: [PortfolioProperty] { properties(for: propertyInputs) }

    // ─── Computed summary ─────────────────────────────────────────────────────

    static func summary(for inputs: [PropertyInput]) -> PortfolioSummary {
        let vals = valuations(for: inputs)
        let totalInvested = Double(inputs.reduce(0) { $0 + $1.purchasePrice })
        let totalHighValue = vals.reduce(0.0) { $0 + Formatters.roundToDisplayPrecision($1.highValue) }
        let totalGrowth = totalHighValue - totalInvested
        let growthPercent = totalInvested > 0 ? (totalGrowth / totalInvested) * 100 : 0.0
        let totalAnnualRental = Double(inputs.reduce(0) { $0 + $1.monthlyRent * 12 })

        return PortfolioSummary(
            netWorth: Formatters.formatAmount(totalHighValue),
            invested: Formatters.formatAmount(totalInvested),
            estGrowth: Formatters.formatAmount(totalGrowth),
            estGrowthPercent: String(format: "%.1f%%", growthPercent),
            annualRental: Formatters.formatAmount(totalAnnualRental)
        )
    }

    static var summary: PortfolioSummary { summary(for: propertyInputs) }

    // ─── Property detail (index 2 — Old Home in Vasundhra) ───────────────────

    static var propertyDetail: PropertyDetail {
        let vals = valuations
        let v = vals[2]
        let p = v.input
        let annualRent = Double(p.monthlyRent) * 12
        let rentalYield = v.fairValue > 0 ? (annualRent / v.fairValue) * 100 : 0.0

        return PropertyDetail(
            title: p.projectName,
            location: "\(p.locality), \(p.city)",
            status: p.monthlyRent > 0 ? "Rent" : "Self Use",
            estValueRange: Formatters.formatValueRange(low: v.lowValue, high: v.highValue),
            invested: Formatters.formatAmount(Double(p.purchasePrice)),
            estGrowth: Formatters.formatAmount(v.growth),
            estGrowthPercent: p.purchasePrice > 0
                ? String(format: "%.1f%%", (v.growth / Double(p.purchasePrice)) * 100) : "0%",
            annualRental: Formatters.formatAmount(annualRent),
            comparisonYear: "Jan \(p.purchaseYear)",
            comparisonInvested: Formatters.formatAmount(Double(p.purchasePrice)),
            propertyReturn: p.purchasePrice > 0
                ? String(format: "%.1f%%", (v.growth / Double(p.purchasePrice)) * 100) : "0%",
            goldReturn: String(format: "%.1f%%", 10.0 * Double(2025 - p.purchaseYear)),
            niftyReturn: String(format: "%.1f%%", 12.0 * Double(2025 - p.purchaseYear)),
            yearsLabel: "in \(2025 - p.purchaseYear)yrs",
            monthlyRental: Formatters.formatRent(Double(p.monthlyRent)),
            annualRentalDetail: Formatters.formatAmount(annualRent),
            rentalYield: String(format: "%.1f%%", rentalYield),
            rentDueDay: "23 of every month",
            leaseRenewal: "23 Jan every year",
            insightLoss: "You're losing approx. ₹7,000 monthly",
            insightOpportunity: "Similar properties get up to ₹37,000 per month",
            activeTenants: "212 active tenants",
            tenantGrowth: "4.2% increase this month/from last year",
            postedForRent: "112 posted for rent",
            postedGrowth: "1.2% increase this month/from last year"
        )
    }
}
