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

                    // Valuation status banner
                    valuationBanner

                    // Hero section
                    PortfolioSummaryHeroView(
                        summary: summary,
                        lastUpdated: repository.oldestValuationDate
                    )

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
            .refreshable {
                await repository.wakeServer()
                await repository.refreshValuations(force: true)
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
                apiSummary = nil
                apiProperties = nil
            }
        }
        .task(id: "valuation-\(repository.propertyInputs.count)") {
            // Wake the server first to reduce cold-start latency
            await repository.wakeServer()
            // Then refresh valuations
            await repository.refreshValuations()
        }
    }

    // ─── Valuation status banner ─────────────────────────────────────────────

    @ViewBuilder
    private var valuationBanner: some View {
        switch repository.valuationState {
        case .loading(let startedAt):
            let elapsed = Date().timeIntervalSince(startedAt)
            HStack(spacing: Spacing.l) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(elapsed > 10 ? "This may take a moment (waking up server)..." : "Updating valuations...")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.l)
            .background(Color.insightBaseUltralight)

        case .failed(let error, _):
            HStack(spacing: Spacing.l) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 14))
                Text(error.userMessage + " Showing cached values.")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
                Spacer()
                Button("Retry") {
                    Task {
                        await repository.wakeServer()
                        await repository.refreshValuations(force: true)
                    }
                }
                .font(Typography.bodySmall)
                .foregroundColor(.brandPrimary)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.l)
            .background(Color(red: 1, green: 0.97, blue: 0.93))

        default:
            if repository.isValuationOutdated {
                HStack(spacing: Spacing.l) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    Text("Valuations may be outdated. Pull down to refresh.")
                        .font(Typography.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, Spacing.l)
                .background(Color(red: 1, green: 0.97, blue: 0.93))
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
