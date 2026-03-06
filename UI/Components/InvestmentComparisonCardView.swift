import SwiftUI

struct InvestmentComparisonCardView: View {
    let detail: PropertyDetail

    // Icon colors — rgb values from Figma
    private let indigoBg  = Color(red: 0.388, green: 0.400, blue: 0.945)
    private let amberBg   = Color(red: 0.918, green: 0.702, blue: 0.031)
    private let emeraldBg = Color(red: 0.063, green: 0.725, blue: 0.506)

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Header
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Investment Comparison")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
                Text("If \(detail.comparisonInvested) was invested in \(detail.comparisonYear)")
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.black.opacity(0.5))
            }

            // Beige card — three equal-width columns
            HStack(alignment: .top, spacing: 0) {
                comparisonColumn(
                    icon: "house.fill",
                    iconBg: indigoBg.opacity(0.1),
                    iconTint: indigoBg,
                    label: "Your Property",
                    crown: true,
                    value: detail.propertyReturn,
                    winner: true
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                comparisonColumn(
                    icon: "indianrupeesign.circle.fill",
                    iconBg: amberBg.opacity(0.1),
                    iconTint: amberBg,
                    label: "Gold",
                    crown: false,
                    value: detail.goldReturn,
                    winner: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                comparisonColumn(
                    icon: "chart.line.uptrend.xyaxis",
                    iconBg: emeraldBg.opacity(0.1),
                    iconTint: emeraldBg,
                    label: "Nifty 50",
                    crown: false,
                    value: detail.niftyReturn,
                    winner: false
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.l)
            .background(Color.surfaceAccentBase)
            .clipShape(RoundedRectangle(cornerRadius: Radius.element))
        }
    }

    @ViewBuilder
    private func comparisonColumn(
        icon: String,
        iconBg: Color,
        iconTint: Color,
        label: String,
        crown: Bool,
        value: String,
        winner: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxl) {
            // Icon — 32×32 rounded-8
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBg)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(iconTint)
            }

            // Label + divider
            VStack(alignment: .leading, spacing: Spacing.m) {
                HStack(spacing: Spacing.s) {
                    if crown {
                        Image(systemName: "crown.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                    Text(label)
                        .font(Typography.bodySmall)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundColor(.textPrimary)
                .opacity(0.93)

                Divider().overlay(Color.borderSubtle)
            }

            // Return %
            Text(value)
                .font(winner ? Typography.priceLabel : .system(size: 20, weight: .regular))
                .tracking(-0.4)
                .lineLimit(1)
                .foregroundColor(winner ? .textPrimary : .textSecondary)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.l)
    }
}

#Preview {
    InvestmentComparisonCardView(detail: SamplePortfolioData.propertyDetail)
        .padding(.horizontal, Spacing.xxxl)
}
