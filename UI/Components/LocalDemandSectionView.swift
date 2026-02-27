import SwiftUI

struct LocalDemandSectionView: View {
    let detail: PropertyDetail

    @State private var selectedTab = "Rent"
    private let tabs = ["Sell", "Rent", "Label"]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Header row: icon + title + segment control
            HStack(alignment: .top) {
                HStack(alignment: .top, spacing: Spacing.l) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Local Demand (Last 1 year)")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)
                        Text("based on similar properties on 99acres")
                            .font(Typography.bodySmallThin)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                // Segment control
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            Text(tab)
                                .font(selectedTab == tab ? Typography.bodySmall : Typography.bodySmallThin)
                                .foregroundColor(selectedTab == tab ? .textPrimary : .textSecondary)
                                .padding(.horizontal, Spacing.xl)
                                .padding(.vertical, Spacing.s)
                                .background(
                                    selectedTab == tab
                                        ? Color.surfaceWhite
                                        : Color.clear
                                )
                                .clipShape(Capsule())
                                .shadow(
                                    color: selectedTab == tab ? .shadowNeutralLow : .clear,
                                    radius: selectedTab == tab ? Elevation.cardShadow : 0,
                                    y: selectedTab == tab ? 1 : 0
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Spacing.xs)
                .background(Color.surfaceLowContrast)
                .clipShape(Capsule())
            }

            // Single bordered card with divider
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                // Active tenants
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text(detail.activeTenants)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textGreen)
                        Text(detail.tenantGrowth)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }

                Divider().overlay(Color.borderSubtle)

                // Posted for rent
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text(detail.postedForRent)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textGreen)
                        Text(detail.postedGrowth)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(Spacing.xxxl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceWhite)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(Color.borderSubtle, lineWidth: 1)
            )
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxl)
    }
}

#Preview {
    LocalDemandSectionView(detail: SamplePortfolioData.propertyDetail)
}
