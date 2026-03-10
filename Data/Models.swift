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
    let isValuationPending: Bool
    /// Valuation confidence level — "high", "medium", "low", or nil if no valuation.
    let confidence: String?
    /// Valuation source — "parsed", "project_page", "fallback", "failed", or nil.
    let valuationSource: String?

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
        isNew: Bool = false,
        isValuationPending: Bool = false,
        confidence: String? = nil,
        valuationSource: String? = nil
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
        self.isValuationPending = isValuationPending
        self.confidence = confidence
        self.valuationSource = valuationSource
    }

    /// True when the valuation is a low-confidence city-average fallback.
    var isFallbackValuation: Bool {
        valuationSource == "fallback" && confidence == "low"
    }

    /// True when the valuation confidence is too low to display (locality fallback, city fallback, etc.)
    var isLowConfidenceValuation: Bool {
        confidence == "low" || isFallbackValuation
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

// ─── Valuation State & Error ─────────────────────────────────────────────────

enum ValuationState: Equatable {
    case idle
    case loading(startedAt: Date)
    case succeeded(at: Date)
    case failed(error: ValuationError, at: Date)
}

/// Context for toast display — identifies what triggered the last successful valuation refresh.
enum RefreshContext: Equatable {
    case singleProperty(name: String)
    case allProperties
}

enum ValuationError: Error, Equatable {
    case networkError(String)
    case timeout
    case serverError(Int)
    case decodingError(String)

    var userMessage: String {
        switch self {
        case .networkError: return "Couldn't connect to valuation server."
        case .timeout: return "Valuation request timed out."
        case .serverError(let code): return "Server error (\(code))."
        case .decodingError: return "Unexpected response from server."
        }
    }
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
    let bhkFiltered: Bool
    let sizeFiltered: Bool
    let filterFallback: String
    let warnings: [String]
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
    let bhkFiltered: Bool?
    let sizeFiltered: Bool?
    let filterFallback: String?
    let warnings: [String]?
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
