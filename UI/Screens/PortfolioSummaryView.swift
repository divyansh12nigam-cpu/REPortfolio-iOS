import SwiftUI

struct PortfolioSummaryView: View {
    var onPropertyTap: (Int) -> Void = { _ in }
    var onAddClick: () -> Void = {}
    var onEditProperty: (Int) -> Void = { _ in }
    /// Triggered by the "Add Purchase Price" strip — opens edit flow at Step 2, purchase price focused.
    var onAddPurchasePrice: (Int) -> Void = { _ in }

    @Environment(\.openURL) private var openURL

    @StateObject private var repository = PropertyRepository.shared
    @State private var apiSummary: PortfolioSummary? = nil
    @State private var apiProperties: [PortfolioProperty]? = nil
    @State private var propertyToDeleteIndex: Int? = nil

    /// Real 99acres valuations from the valuation service (cached in repository).
    /// Nil when no cached valuations exist — falls back to hardcoded city prices.
    private var realValuations: [String: CachedValuation]? {
        repository.valuations.isEmpty ? nil : repository.valuations
    }

    /// Always derived from the latest repository state — updates instantly.
    /// Uses real 99acres valuations when available, hardcoded city prices as fallback.
    private var summary: PortfolioSummary {
        apiSummary ?? SamplePortfolioData.summary(
            for: repository.propertyInputs,
            realValuations: realValuations
        )
    }

    private var properties: [PortfolioProperty] {
        apiProperties ?? SamplePortfolioData.properties(
            for: repository.propertyInputs,
            newCount: repository.addedCount,
            realValuations: realValuations
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Page header
                    PortfolioPageHeaderView()

                    // Hero section
                    PortfolioSummaryHeroView(summary: summary)

                    // "YOUR PROPERTIES (N)" + "+ Add" row
                    propertiesSectionHeader

                    // Property cards
                    ForEach(Array(properties.enumerated()), id: \.element.id) { index, property in
                        VStack(spacing: property.cardVariant == .plain ? 0 : -Spacing.xxl) {
                            SwipeableCardView(
                                onEdit: { onEditProperty(index) },
                                onDelete: { propertyToDeleteIndex = index }
                            ) {
                                PropertyCardBodyView(
                                    property: property,
                                    onClick: { onPropertyTap(index) }
                                )
                            }
                            .zIndex(2)

                            PropertyCardStripView(
                                property: property,
                                onInsightTap: {
                                    guard index < repository.propertyInputs.count,
                                          let url = NinetyNineAcresURL.search(for: repository.propertyInputs[index])
                                    else { return }
                                    openURL(url)
                                },
                                onPostNowTap: {
                                    openURL(NinetyNineAcresURL.postProperty)
                                },
                                onAddPurchasePriceTap: {
                                    onAddPurchasePrice(index)
                                }
                            )
                            .zIndex(1)
                        }
                        .padding(.horizontal, Spacing.xxxl)
                        .padding(.bottom, Spacing.xxxl)
                    }

                    // Sticky bottom CTA (inside scroll on summary screen — matches Android)
                    StickyBottomButtonsView()

                    // Disclaimer
                    DisclaimerFooterView()
                }
            }
            .background(Color.surfaceWhite)

            StatusBarFadeOverlay()
        }
        .alert("Delete Property", isPresented: Binding(
            get: { propertyToDeleteIndex != nil },
            set: { if !$0 { propertyToDeleteIndex = nil } }
        )) {
            Button("Cancel", role: .cancel) { propertyToDeleteIndex = nil }
            Button("Delete", role: .destructive) {
                if let index = propertyToDeleteIndex {
                    withAnimation { repository.removeProperty(at: index) }
                    // Clear API cache so local computation picks up immediately
                    apiSummary = nil
                    apiProperties = nil
                }
                propertyToDeleteIndex = nil
            }
        } message: {
            Text("Are you sure you want to remove this property from your portfolio?")
        }
        .task(id: repository.propertyInputs.count) {
            // Try API as an optional upgrade over local computation
            do {
                let response = try await PortfolioApi.fetchSummary(inputs: repository.propertyInputs)
                if !Task.isCancelled {
                    apiSummary    = response.summary.toUiSummary()
                    apiProperties = response.properties.enumerated().map { i, p in
                        p.toUiProperty(variant: .plain)
                    }
                }
            } catch {
                // Clear API state so computed properties use local data
                apiSummary = nil
                apiProperties = nil
            }
        }
        .task(id: "valuation-\(repository.propertyInputs.count)") {
            // Always refresh on launch — service caches internally, so this is cheap for repeat calls
            print("[ValuationRefresh] Triggering refresh for \(repository.propertyInputs.count) properties")
            await repository.refreshValuations()
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
