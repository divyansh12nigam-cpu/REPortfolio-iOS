import SwiftUI

struct PropertySummaryHeroView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Property name + status + 3-dot menu
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(detail.title)
                        .font(Typography.titleSmall)
                        .foregroundColor(.textPrimary)
                    Text(detail.location)
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                HStack(spacing: Spacing.s) {
                    // Status pill
                    Text("✓ \(detail.status)")
                        .font(Typography.captionMed)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.s)
                        .background(Color.surfaceWhite.opacity(0.6))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.borderSubtle, lineWidth: 1))

                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.textPrimary)
                }
            }

            // Estimated value
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Estimated current value")
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textSecondary)
                Text(detail.estValueRange)
                    .font(Typography.displaySmall)
                    .tracking(-0.72)
                    .foregroundColor(.textPrimary)
            }

            // "+ Add exact value" + info row
            HStack(spacing: Spacing.l) {
                Button(action: {}) {
                    Text("+ Add exact value")
                        .font(Typography.bodySmall)
                        .foregroundColor(.brandPrimary)
                }
                HStack(spacing: Spacing.xs) {
                    Text("Why add exact value?")
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }

            Divider().overlay(Color.borderSubtle)

            // 4-column stats
            HStack(alignment: .top) {
                PropertyStatView(label: "Invested",     value: detail.invested)
                Spacer()
                PropertyStatView(label: "Est. Growth",  value: detail.estGrowth)
                Spacer()
                PropertyStatGreenView(label: "Est. %Growth", value: detail.estGrowthPercent)
                Spacer()
                PropertyStatView(label: "Annual Rental", value: detail.annualRental)
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.insightBaseUltralight, .insightBaseLight],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    }
}

private struct PropertyStatView: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label).font(Typography.bodySmallThin).foregroundColor(.textSecondary)
            Text(value).font(Typography.bodyLarge).foregroundColor(.textPrimary)
        }
    }
}

private struct PropertyStatGreenView: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label).font(Typography.bodySmallThin).foregroundColor(.textSecondary)
            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textGreen)
                Text(value).font(Typography.bodyLarge).foregroundColor(.textGreen)
            }
        }
    }
}

#Preview {
    PropertySummaryHeroView(detail: SamplePortfolioData.propertyDetail)
}
