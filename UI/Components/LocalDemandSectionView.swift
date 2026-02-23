import SwiftUI

struct LocalDemandSectionView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("LOCAL DEMAND")
                .font(Typography.overline)
                .tracking(0.88)
                .foregroundColor(.textSecondary)

            HStack(spacing: Spacing.xl) {
                DemandCard(
                    value: detail.activeTenants,
                    growth: detail.tenantGrowth,
                    label: "Active Tenants"
                )
                DemandCard(
                    value: detail.postedForRent,
                    growth: detail.postedGrowth,
                    label: "Posted for Rent"
                )
            }
        }
        .padding(.horizontal, Spacing.xxxl)
    }
}

private struct DemandCard: View {
    let value: String
    let growth: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(value)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textPrimary)
                Text(label)
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textSecondary)
            }
            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textGreen)
                Text(growth)
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceLowContrast)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

#Preview {
    LocalDemandSectionView(detail: SamplePortfolioData.propertyDetail)
}
