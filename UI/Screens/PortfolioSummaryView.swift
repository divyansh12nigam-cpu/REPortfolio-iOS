import SwiftUI

struct PortfolioSummaryView: View {
    var onPropertyTap: (Int) -> Void = { _ in }
    var onAddClick: () -> Void = {}
    var onEditProperty: (Int) -> Void = { _ in }
    /// Triggered by the "Add Purchase Price" strip — opens edit flow at Step 2, purchase price focused.
    var onAddPurchasePrice: (Int) -> Void = { _ in }
    var onProfileTap: () -> Void = {}

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
            realValuations: realValuations,
            valuationState: repository.valuationState
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Page header
                    PortfolioPageHeaderView(isRootScreen: true, onBack: onProfileTap)

                    if properties.isEmpty {
                        // Empty state for new users
                        emptyStateView
                    } else {
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
                                    onDelete: { propertyToDeleteIndex = index },
                                    onRefresh: {
                                        guard index < repository.propertyInputs.count else { return }
                                        Task {
                                            await repository.wakeServer()
                                            await repository.refreshSingleValuation(
                                                for: repository.propertyInputs[index]
                                            )
                                        }
                                    }
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
            // Skip if SuccessView already kicked off a refresh that's still running
            guard !repository.isRefreshingValuations else {
                print("[ValuationRefresh] Already in progress — skipping")
                return
            }
            // Skip if a refresh just completed (SuccessView's refresh finished during animation)
            if case .succeeded(let at) = repository.valuationState,
               Date().timeIntervalSince(at) < 30 {
                print("[ValuationRefresh] Just completed \(Int(Date().timeIntervalSince(at)))s ago — skipping")
                return
            }
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

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer().frame(height: Spacing.widgetsM)

            Image(systemName: "building.2.fill")
                .font(.system(size: 56))
                .foregroundColor(.brandPrimary)

            Text("Your portfolio is empty")
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)

            Text("Add your first property to start\ntracking your real estate wealth")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: Spacing.xl)

            Button(action: onAddClick) {
                HStack(spacing: Spacing.l) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Property")
                        .font(Typography.bodyLarge)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brandPrimary)
                .cornerRadius(Radius.sm)
            }
            .padding(.horizontal, Spacing.xxxl)

            Spacer()
        }
        .frame(maxWidth: .infinity)
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
