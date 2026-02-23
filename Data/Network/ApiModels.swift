import Foundation

// ─── Request ──────────────────────────────────────────────────────────────────

struct PortfolioRequest: Encodable {
    let properties: [PropertyInputDTO]
}

struct PropertyInputDTO: Encodable {
    let projectName: String
    let city: String
    let locality: String
    let areaSqft: Int
    let purchasePrice: Int64
    let purchaseYear: Int
    let monthlyRent: Int
}

// ─── Response ─────────────────────────────────────────────────────────────────

struct PortfolioApiResponse: Decodable {
    let summary: ApiSummary
    let properties: [ApiProperty]
}

struct ApiSummary: Decodable {
    let total_invested: Double
    let total_current_value: Double
    let total_growth: Double
    let portfolio_growth_percent: Double
    let total_annual_rental: Double
}

struct ApiProperty: Decodable {
    let projectName: String
    let value_range_low: Double
    let value_range_high: Double
    let fair_value: Double
    let growth: Double
    let growth_percent: Double
    let monthly_rent: Double
    let annual_rent: Double
    let status: String
}

// ─── Mapping: API → UI models ─────────────────────────────────────────────────

extension ApiSummary {
    func toUiSummary() -> PortfolioSummary {
        PortfolioSummary(
            netWorth: Formatters.formatAmount(total_current_value),
            invested: Formatters.formatAmount(total_invested),
            estGrowth: Formatters.formatAmount(total_growth),
            estGrowthPercent: total_invested > 0
                ? String(format: "%.1f%%", (total_growth / total_invested) * 100) : "0%",
            annualRental: Formatters.formatAmount(total_annual_rental)
        )
    }
}

extension ApiProperty {
    func toUiProperty(variant: PropertyCardVariant = .plain) -> PortfolioProperty {
        PortfolioProperty(
            title: projectName,
            status: status,
            estValue: Formatters.formatValueRange(low: value_range_low, high: value_range_high),
            estGrowth: Formatters.formatAmount(growth),
            monthlyRental: Formatters.formatRent(monthly_rent),
            cardVariant: variant
        )
    }
}
