import SwiftUI

struct PropertyDetailView: View {
    var onBack: () -> Void = {}

    let detail: PropertyDetail

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        PortfolioPageHeaderView(
                            title: detail.title,
                            showRightButton: false,
                            onBack: onBack
                        )

                        PropertySummaryHeroView(detail: detail)

                        Spacer().frame(height: Spacing.widgetsM)

                        InvestmentComparisonCardView(detail: detail)
                            .padding(.horizontal, Spacing.xxxl)

                        Spacer().frame(height: Spacing.widgetsM)

                        RentalDetailsCardView(detail: detail)

                        Spacer().frame(height: Spacing.widgetsM)

                        LocalDemandSectionView(detail: detail)

                        Spacer().frame(height: Spacing.widgetsM)

                        // Simple text disclaimer (matches Figma)
                        Text("*Disclaimer: Prices mentioned above are estimates based on properties posted on 99acres and do not suggest accurate value.")
                            .font(Typography.bodySmallThin)
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, Spacing.xxxl)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer().frame(height: Spacing.widgetsM)
                    }
                }

                // Sticky bottom bar — outside ScrollView, always visible
                PropertyDetailBottomBarView()
            }
            .background(Color.surfaceWhite)

            StatusBarFadeOverlay()
        }
    }
}

#Preview {
    PropertyDetailView(detail: SamplePortfolioData.propertyDetail)
}
