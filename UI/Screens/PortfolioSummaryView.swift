import SwiftUI

struct PortfolioSummaryView: View {
    var onPropertyTap: () -> Void = {}
    var onAddClick: () -> Void = {}

    @StateObject private var repository = PropertyRepository.shared
    @State private var summary    = SamplePortfolioData.summary
    @State private var properties = SamplePortfolioData.properties
    @State private var isLoading  = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Page header
                PortfolioPageHeaderView()

                // Hero section
                PortfolioSummaryHeroView(summary: summary)

                // "YOUR PROPERTIES (N)" + "+ Add" row
                propertiesSectionHeader

                // Property cards or loading indicator
                if isLoading {
                    ProgressView()
                        .tint(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    ForEach(properties) { property in
                        PortfolioPropertyCardView(property: property, onClick: onPropertyTap)
                            .padding(.horizontal, Spacing.xxxl)
                            .padding(.bottom, Spacing.xxxl)
                    }
                }

                // Sticky bottom CTA (inside scroll on summary screen — matches Android)
                StickyBottomButtonsView()

                // Disclaimer
                DisclaimerFooterView()
            }
        }
        .background(Color.surfaceWhite)
        .task(id: repository.propertyInputs.count) {
            isLoading = true
            defer { isLoading = false }
            do {
                let response = try await PortfolioApi.fetchSummary(inputs: repository.propertyInputs)
                summary    = response.summary.toUiSummary()
                properties = response.properties.enumerated().map { i, p in
                    p.toUiProperty(variant: .plain)
                }
            } catch {
                // Sample data remains as fallback
            }
        }
    }

    private var propertiesSectionHeader: some View {
        HStack {
            Text("YOUR PROPERTIES (\(properties.count))")
                .font(Typography.overline)
                .tracking(0.88)
                .foregroundColor(.textPrimary)
            Spacer()
            // "+ Add" ghost pill button
            Button(action: onAddClick) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.brandPrimary)
                    Text("Add")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.brandText)
                }
                .padding(.horizontal, Spacing.xxl)
                .frame(height: 36)
                .overlay(
                    Capsule().stroke(Color.borderSubtle, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.widgetsM)
        .padding(.bottom, Spacing.xxl)
    }
}

#Preview {
    PortfolioSummaryView()
}
