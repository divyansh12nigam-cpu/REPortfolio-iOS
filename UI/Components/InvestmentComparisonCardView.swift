import SwiftUI

struct InvestmentComparisonCardView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Card title (two-line with different styles)
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("If \(detail.comparisonInvested) was invested in \(detail.comparisonYear):")
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textSecondary)
                Text("Property vs Gold vs Equity")
                    .font(Typography.titleSmall)
                    .foregroundColor(.textPrimary)
            }

            // Comparison columns container
            HStack(spacing: Spacing.s) {
                // Your Property — card (elevated, white bg)
                VStack(spacing: Spacing.s) {
                    BarChartView(heightFraction: 0.85, color: .brandPrimary)
                    HStack(spacing: Spacing.xs) {
                        Text("Your Property").font(Typography.bodySmallThin).foregroundColor(.textSecondary)
                        Text("🎉").font(.system(size: 12))
                    }
                    Text(detail.propertyReturn)
                        .font(Typography.priceLabel)
                        .foregroundColor(.textPrimary)
                    Text(detail.yearsLabel)
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textDisabled)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xl)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceWhite)
                .clipShape(RoundedRectangle(cornerRadius: Radius.element))
                .shadow(color: .shadowNeutralLow, radius: Elevation.cardShadow, x: 0, y: 2)

                // Gold column
                ComparisonColumnView(
                    heightFraction: 0.55, barColor: Color(hex: "FFD700"),
                    label: "Gold", returnPercent: detail.goldReturn, yearsLabel: detail.yearsLabel
                )
                .frame(maxWidth: .infinity)

                // Nifty 50 column
                ComparisonColumnView(
                    heightFraction: 0.65, barColor: Color(hex: "4CAF50"),
                    label: "Nifty 50", returnPercent: detail.niftyReturn, yearsLabel: detail.yearsLabel
                )
                .frame(maxWidth: .infinity)
            }
            .padding(Spacing.s)
            .background(Color.surfaceLowContrast)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        }
    }
}

private struct ComparisonColumnView: View {
    let heightFraction: Double
    let barColor: Color
    let label: String
    let returnPercent: String
    let yearsLabel: String

    var body: some View {
        VStack(spacing: Spacing.s) {
            BarChartView(heightFraction: heightFraction, color: barColor)
            Text(label).font(Typography.bodySmallThin).foregroundColor(.textSecondary)
            Text(returnPercent).font(Typography.priceLabel).foregroundColor(.textPrimary)
            Text(yearsLabel).font(Typography.bodySmallThin).foregroundColor(.textDisabled)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.xl)
    }
}

/// Simple bar chart placeholder (replaces expiring Figma asset URLs)
private struct BarChartView: View {
    let heightFraction: Double  // 0.0 – 1.0
    let color: Color
    private let maxHeight: CGFloat = 80

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.2))
                .frame(width: 32, height: maxHeight * heightFraction)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: 32, height: maxHeight * heightFraction * 0.3)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                )
        }
        .frame(width: 48, height: maxHeight)
    }
}

#Preview {
    InvestmentComparisonCardView(detail: SamplePortfolioData.propertyDetail)
        .padding(.horizontal, Spacing.xxxl)
}
