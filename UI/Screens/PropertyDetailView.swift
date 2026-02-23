import SwiftUI

struct PropertyDetailView: View {
    var onBack: () -> Void = {}

    let detail: PropertyDetail

    var body: some View {
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

                    DisclaimerFooterView()

                    Spacer().frame(height: Spacing.widgetsM)
                }
            }

            // Sticky bottom bar — outside ScrollView, always visible
            PropertyDetailBottomBarView()
        }
        .background(Color.surfaceWhite)
    }
}

#Preview {
    PropertyDetailView(detail: SamplePortfolioData.propertyDetail)
}
