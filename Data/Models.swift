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
    let id = UUID()
    let title: String
    let status: String
    let estValue: String
    let estGrowth: String
    let monthlyRental: String
    let cardVariant: PropertyCardVariant
    let insightText: String
    let actionLabel: String

    init(
        title: String,
        status: String,
        estValue: String,
        estGrowth: String,
        monthlyRental: String,
        cardVariant: PropertyCardVariant,
        insightText: String = "",
        actionLabel: String = ""
    ) {
        self.title = title
        self.status = status
        self.estValue = estValue
        self.estGrowth = estGrowth
        self.monthlyRental = monthlyRental
        self.cardVariant = cardVariant
        self.insightText = insightText
        self.actionLabel = actionLabel
    }
}

// ─── Onboarding enums + form state ──────────────────────────────────────────

enum PropertyUsageType: String, CaseIterable {
    case selfUse = "Self-use"
    case rentLease = "Rent/lease"
    case investment = "Investment"
}

enum FloorPlan: String, CaseIterable {
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
