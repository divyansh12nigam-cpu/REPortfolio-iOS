import Foundation

// ─── Portfolio Summary ────────────────────────────────────────────────────────

struct PortfolioSummary {
    let netWorth: String
    let invested: String
    let estGrowth: String
    let estGrowthPercent: String
    let annualRental: String
}

// ─── Property Card Variant ────────────────────────────────────────────────────

enum PropertyCardVariant {
    case plain
    case insight
    case insightAction
    case addPurchasePrice
}

// ─── Portfolio Property (card list item) ─────────────────────────────────────

struct PortfolioProperty: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let status: String
    let estValue: String
    let estGrowth: String
    let monthlyRental: String
    let cardVariant: PropertyCardVariant
    let insightText: String
    let actionLabel: String
    let isNew: Bool

    init(
        id: String,
        title: String,
        subtitle: String = "",
        status: String,
        estValue: String,
        estGrowth: String,
        monthlyRental: String,
        cardVariant: PropertyCardVariant,
        insightText: String = "",
        actionLabel: String = "",
        isNew: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.estValue = estValue
        self.estGrowth = estGrowth
        self.monthlyRental = monthlyRental
        self.cardVariant = cardVariant
        self.insightText = insightText
        self.actionLabel = actionLabel
        self.isNew = isNew
    }
}

// ─── Onboarding enums + form state ──────────────────────────────────────────

enum PropertyUsageType: String, CaseIterable, Codable {
    case selfUse = "Self-use"
    case rentLease = "Rent/lease"
    case investment = "Investment"
}

enum FloorPlan: String, CaseIterable, Codable {
    case bhk2 = "2 BHK"
    case bhk3 = "3 BHK"
    case bhk4 = "4 BHK"
    case other = "Other"
}

struct OnboardingFormState {
    // Step 1
    var city: String = ""
    var locality: String = ""
    var societyName: String = ""
    var floorPlan: FloorPlan? = nil
    var areaSqft: String = ""
    // Step 2
    var usageType: PropertyUsageType? = nil
    var purchasePrice: String = ""
    var purchaseYear: String = ""
    var purchaseMonth: String = ""
    var monthlyRent: String = ""
    var customName: String = ""
}

// ─── Cached Valuation (from 99acres valuation service) ───────────────────────

struct CachedValuation: Codable {
    let valueLow: Double
    let valueHigh: Double
    let fairValue: Double
    let pricePerSqft: Double
    let growth: Double
    let growthPercent: Double
    let source: String
    let confidence: String
    let comparableCount: Int
    let fetchedAt: Date
}

// ─── Valuation API DTOs ──────────────────────────────────────────────────────

struct ValuationBatchRequest: Encodable {
    let properties: [ValuationInputDTO]
}

struct ValuationInputDTO: Encodable {
    let projectName: String
    let city: String
    let locality: String
    let societyName: String
    let areaSqft: Int
    let purchasePrice: Int64
    let monthlyRent: Int
    let floorPlan: String?
}

struct ValuationBatchResponse: Decodable {
    let valuations: [ApiValuation]
    let summary: ApiValuationSummary
}

struct ApiValuation: Decodable {
    let projectName: String
    let valueLow: Double
    let valueHigh: Double
    let fairValue: Double
    let pricePerSqft: Double
    let growth: Double
    let growthPercent: Double
    let monthlyRent: Double
    let annualRent: Double
    let status: String
    let source: String
    let searchTier: String
    let confidence: String
    let comparableCount: Int
    let cachedAt: String
}

struct ApiValuationSummary: Decodable {
    let totalInvested: Double
    let totalCurrentValue: Double
    let totalGrowth: Double
    let growthPercent: Double
    let totalAnnualRental: Double
}

// ─── Property Detail ──────────────────────────────────────────────────────────

struct PropertyDetail {
    let title: String
    let location: String
    let status: String
    let estValueRange: String
    let invested: String
    let estGrowth: String
    let estGrowthPercent: String
    let annualRental: String
    // Investment comparison
    let comparisonYear: String
    let comparisonInvested: String
    let propertyReturn: String
    let goldReturn: String
    let niftyReturn: String
    let yearsLabel: String
    // Rental
    let monthlyRental: String
    let annualRentalDetail: String
    let rentalYield: String
    let rentDueDay: String
    let leaseRenewal: String
    let insightLoss: String
    let insightOpportunity: String
    // Local demand
    let activeTenants: String
    let tenantGrowth: String
    let postedForRent: String
    let postedGrowth: String
}
