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
