import SwiftUI

struct PropertySummaryHeroView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxl) {
            // Property name + status tag + 3-dot menu
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(detail.title)
                        .font(Typography.priceLabel)
                        .tracking(-0.4)
                        .foregroundColor(.textPrimary)
                    Text(detail.location)
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                Spacer()
                HStack(spacing: Spacing.l) {
                    // Status pill — checkmark + label
                    HStack(spacing: Spacing.m) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                        Text(detail.status)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.s)
                    .background(Color.surfaceLowContrast)
                    .clipShape(Capsule())

                    // 3-dot menu in white circle
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(width: 28, height: 28)
                        .background(Color.surfaceWhite)
                        .clipShape(Circle())
                }
            }

            // Estimated value section
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Estimated current value")
                        .font(Typography.bodySmall)
                        .foregroundColor(.textPrimary)
                    Text(detail.estValueRange)
                        .font(Typography.displaySmall)
                        .tracking(-0.72)
                        .foregroundColor(.textPrimary)
                }

                // "+ Add exact value" + "Why add exact value?"
                HStack(spacing: Spacing.l) {
                    Button(action: {}) {
                        HStack(spacing: Spacing.s) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Add exact value")
                                .font(Typography.bodySmall)
                        }
                        .foregroundColor(.brandPrimary)
                    }

                    HStack(spacing: Spacing.xs) {
                        Text("Why add exact value?")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Thin divider
            Divider().overlay(Color.borderSubtle)

            // 4-column stats row
            HStack(alignment: .center) {
                PropertyStatView(label: "Invested", value: detail.invested)
                Spacer()
                PropertyStatView(label: "Est. Growth", value: detail.estGrowth)
                Spacer()
                // Growth % — ▲ value >
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("Est. %Growth")
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 2) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.textPrimary)
                        Text(detail.estGrowthPercent)
                            .font(Typography.bodyLarge)
                            .foregroundColor(.textPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.textPrimary)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                Spacer()
                PropertyStatView(label: "Annual Rental", value: detail.annualRental)
            }
            .padding(.horizontal, Spacing.xxxl)
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxxxl)
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
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(label)
                .font(Typography.bodySmall)
                .foregroundColor(.textSecondary)
            Text(value)
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    PropertySummaryHeroView(detail: SamplePortfolioData.propertyDetail)
}
