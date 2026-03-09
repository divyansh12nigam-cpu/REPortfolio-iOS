import SwiftUI

// ─── Entry point — convenience wrapper (used by previews) ────────────────────

struct PortfolioPropertyCardView: View {
    let property: PortfolioProperty
    var onClick: () -> Void = {}
    var onInsightTap: (() -> Void)? = nil
    var onPostNowTap: (() -> Void)? = nil
    var onAddPurchasePriceTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: property.cardVariant == .plain ? 0 : -Spacing.xxl) {
            PropertyCardBodyView(property: property, onClick: onClick)
                .zIndex(2)
            PropertyCardStripView(
                property: property,
                onInsightTap: onInsightTap,
                onPostNowTap: onPostNowTap,
                onAddPurchasePriceTap: onAddPurchasePriceTap
            )
            .zIndex(1)
        }
    }
}

// ─── Card body — exposed for PortfolioSummaryView to use directly ────────────

struct PropertyCardBodyView: View {
    let property: PortfolioProperty
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Title row + "New" tag + status badge
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(property.title)
                            .font(Typography.titleSmall)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        if property.isNew {
                            Text("New")
                                .font(Typography.captionMed)
                                .foregroundColor(.surfaceWhite)
                                .padding(.horizontal, Spacing.l)
                                .padding(.vertical, Spacing.xs)
                                .background(Color.brandPrimary)
                                .clipShape(Capsule())
                        }
                    }
                    if !property.subtitle.isEmpty {
                        Text(property.subtitle)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Text(property.status)
                    .font(Typography.captionMed)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, Spacing.xxl)
            .padding(.horizontal, Spacing.xxl)

            Spacer().frame(height: Spacing.xxxl)

            // 3-column stats
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    HStack(spacing: Spacing.s) {
                        estValueText
                        if property.isFallbackValuation {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                        }
                    }
                    Text("Est. Value").font(Typography.bodySmall).foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                StatColumn(label: "Est. Growth",    value: property.estGrowth)
                StatColumn(label: "Monthly Rental", value: property.monthlyRental)
            }
            .padding(.horizontal, Spacing.xxxl)

            Spacer().frame(height: Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .background(Color.surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
        .shadow(color: .shadowNeutralLow, radius: Elevation.cardShadow, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: Radius.card))
        .onTapGesture(perform: onClick)
    }

    // Parse "₹ 1.4 - 1.7Cr" → main + optional Cr suffix
    private var estValueText: some View {
        if property.isValuationPending {
            return AnyView(
                Text("Calculating...")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textSecondary)
            )
        }
        let raw = property.estValue
        let crRange = raw.range(of: "Cr")
        if let range = crRange {
            let mainPart = String(raw[..<range.lowerBound])
            return AnyView(
                (Text(mainPart)
                    .font(Typography.bodyLarge)
                    .tracking(-0.128)
                    .foregroundColor(.textPrimary)
                + Text("Cr")
                    .font(Typography.bodySmall)
                    .tracking(-0.096)
                    .foregroundColor(.textPrimary))
            )
        } else {
            return AnyView(
                Text(raw)
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textPrimary)
            )
        }
    }
}

// ─── Strip view — renders the appropriate strip based on variant ─────────────

struct PropertyCardStripView: View {
    let property: PortfolioProperty
    var onInsightTap: (() -> Void)? = nil
    var onPostNowTap: (() -> Void)? = nil
    var onAddPurchasePriceTap: (() -> Void)? = nil

    // Shared purple shadow color for sparkle icon
    private static let sparkleShadow = Color(hex: "6A51EC").opacity(0.3)

    var body: some View {
        switch property.cardVariant {
        case .plain:
            EmptyView()
        case .insight:
            insightStrip
        case .insightAction:
            insightActionStrip
        case .addPurchasePrice:
            addPurchasePriceStrip
        }
    }

    // Shared sparkle icon with purple drop shadow
    private var sparkleIcon: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 14))
            .foregroundColor(.insightSparkle)
            .shadow(color: Self.sparkleShadow, radius: 4, x: 0, y: 4)
    }

    // Shared purple gradient background + rounded bottom corners
    private var insightGradientBackground: some View {
        LinearGradient(
            colors: [.insightBaseUltralight, .insightBaseLight],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private var bottomRoundedShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            bottomLeadingRadius: Radius.element,
            bottomTrailingRadius: Radius.element
        )
    }

    // ── Insight strip: sparkle + text + chevron right ──
    private var insightStrip: some View {
        Button(action: { onInsightTap?() }) {
            HStack {
                HStack(spacing: Spacing.m) {
                    sparkleIcon
                    Text(property.insightText)
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textPrimary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.widgetsXs)
            .padding(.bottom, Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(insightGradientBackground)
            .clipShape(bottomRoundedShape)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // ── Insight action strip: sparkle + text + "Post property" pill ──
    private var insightActionStrip: some View {
        HStack(spacing: Spacing.xl) {
            sparkleIcon

            Text(property.insightText)
                .font(Typography.bodySmallThin)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { onPostNowTap?() }) {
                Text("Post property")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.xxl)
                    .frame(height: Spacing.widgetsM)
                    .background(Color.surfaceWhite)
                    .clipShape(Capsule())
                    .shadow(color: .shadowNeutralLow, radius: Elevation.cardShadow, x: 0, y: 1)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.widgetsXs)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(insightGradientBackground)
        .clipShape(bottomRoundedShape)
    }

    // ── Add purchase price strip: sparkle + text column + circle plus button ──
    private var addPurchasePriceStrip: some View {
        HStack(spacing: Spacing.xl) {
            sparkleIcon

            VStack(alignment: .leading, spacing: 0) {
                (Text("Add Purchase Price")
                    .fontWeight(.bold)
                + Text(" to view how your property has performed")
                )
                .font(Typography.bodySmallThin)
                .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { onAddPurchasePriceTap?() }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.textPrimary)
                    .frame(width: Spacing.widgetsM, height: Spacing.widgetsM)
                    .background(Color.surfaceWhite)
                    .clipShape(Circle())
                    .shadow(color: .shadowNeutralLow, radius: Elevation.cardShadow, x: 0, y: 1)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.widgetsXs)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(insightGradientBackground)
        .clipShape(bottomRoundedShape)
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

private struct StatColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(value).font(Typography.bodyLarge).foregroundColor(.textPrimary)
            Text(label).font(Typography.bodySmall).foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            PortfolioPropertyCardView(property: SamplePortfolioData.properties[0])
            PortfolioPropertyCardView(property: SamplePortfolioData.properties[1])
            PortfolioPropertyCardView(property: SamplePortfolioData.properties[2])
            PortfolioPropertyCardView(property: SamplePortfolioData.properties[3])
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxxxl)
    }
    .background(Color.surfaceWhite)
}
