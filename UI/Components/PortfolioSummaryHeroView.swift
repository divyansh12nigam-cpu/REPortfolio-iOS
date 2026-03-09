import SwiftUI

struct PortfolioSummaryHeroView: View {
    let summary: PortfolioSummary
    var lastUpdated: Date? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // "YOUR REAL ESTATE NET WORTH" overline
                Text("YOUR REAL ESTATE NET WORTH")
                    .font(Typography.overline)
                    .tracking(0.88)
                    .foregroundColor(.textSecondary)

                Spacer().frame(height: Spacing.l)

                // "Est. ₹2.15 Cr" — mixed font sizes
                HStack(alignment: .bottom, spacing: Spacing.s) {
                    Text("Est.")
                        .font(Typography.priceLabel)
                        .foregroundColor(.textPrimary)
                        .padding(.bottom, Spacing.s)

                    netWorthText
                }

                // "Updated X days ago"
                if let date = lastUpdated {
                    Text(updatedAgoText(from: date))
                        .font(Typography.captionMed)
                        .foregroundColor(.textSecondary)
                        .padding(.top, Spacing.s)
                }

                Spacer().frame(height: Spacing.xxxl)

                Divider()
                    .frame(height: 0.5)
                    .overlay(Color.textSecondary.opacity(0.25))
                    .padding(.horizontal, 26)

                Spacer().frame(height: Spacing.xxl)

                // 4-column stats row
                HStack(alignment: .top) {
                    StatColumnView(label: "Invested",     value: summary.invested)
                    Spacer()
                    StatColumnView(label: "Est. Growth",  value: summary.estGrowth)
                    Spacer()
                    GrowthColumnView(label: "Est. %Growth", value: summary.estGrowthPercent)
                    Spacer()
                    StatColumnView(label: "Annual Rental", value: summary.annualRental)
                }
                .padding(.horizontal, Spacing.xxxl)
            }
            .padding(.vertical, Spacing.xxxxl)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.insightBaseUltralight, .insightBaseLight],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func updatedAgoText(from date: Date) -> String {
        let days = Int(Date().timeIntervalSince(date) / 86400)
        if days == 0 { return "Updated today" }
        if days == 1 { return "Updated yesterday" }
        return "Updated \(days) days ago"
    }

    // Parse "₹2.15 Cr" → main part + optional suffix with mixed font sizes
    private var netWorthText: some View {
        let raw = summary.netWorth
        let hasCr = raw.hasSuffix("Cr")
        let hasL  = !hasCr && raw.hasSuffix("L")
        let suffix = hasCr ? "Cr" : (hasL ? "L" : "")
        let numberPart = suffix.isEmpty ? raw : String(raw.dropLast(suffix.count)).trimmingCharacters(in: .whitespaces)

        return HStack(alignment: .bottom, spacing: 0) {
            Text(numberPart + " ")
                .font(Typography.priceHero)
                .tracking(-0.88)
                .foregroundColor(.textPrimary)
            if !suffix.isEmpty {
                Text(suffix)
                    .font(Typography.priceLabel)
                    .tracking(-0.4)
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 4)
            }
        }
    }
}

// ─── Sub-views ────────────────────────────────────────────────────────────────

private struct StatColumnView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(label).font(Typography.bodySmall).foregroundColor(.textSecondary)
            Text(value).font(Typography.bodyLarge).foregroundColor(.textPrimary)
        }
    }
}

private struct GrowthColumnView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(label).font(Typography.bodySmall).foregroundColor(.textSecondary)
            HStack(spacing: 2) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textGreen)
                Text(value).font(Typography.bodyLarge).foregroundColor(.textPrimary)
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

#Preview {
    PortfolioSummaryHeroView(summary: SamplePortfolioData.summary)
}
