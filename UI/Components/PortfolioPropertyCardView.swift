import SwiftUI

// ─── Entry point — convenience wrapper (used by previews) ────────────────────

struct PortfolioPropertyCardView: View {
    let property: PortfolioProperty
    var onClick: () -> Void = {}
    var onInsightTap: (() -> Void)? = nil
    var onPostNowTap: (() -> Void)? = nil
    var onAddPurchasePriceTap: (() -> Void)? = nil

    var body: some View {
        let stripSpacing: CGFloat = property.cardVariant == .addPurchasePrice
            ? -Spacing.l : -Spacing.xxl

        VStack(spacing: property.cardVariant == .plain ? 0 : stripSpacing) {
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
                    estValueText
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

    // Purple gradient strip
    private var insightStrip: some View {
        Button(action: { onInsightTap?() }) {
            HStack {
                HStack(spacing: Spacing.m) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundColor(.insightSparkle)
                    Text(property.insightText)
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textPrimary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16))
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.widgetsXs)
            .padding(.bottom, Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.surfaceWhite, .purpleLight],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: Radius.element,
                    bottomTrailingRadius: Radius.element
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // Blue strip with "Post now" pill
    private var insightActionStrip: some View {
        HStack(spacing: Spacing.xl) {
            Text(property.insightText)
                .font(Typography.bodySmallThin)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { onPostNowTap?() }) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                    Text("Post now")
                        .font(Typography.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                }
                .padding(.horizontal, Spacing.xl)
                .frame(height: Spacing.widgetsXs)
                .background(Color.surfaceWhite)
                .clipShape(Capsule())
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.widgetsXs)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.insightAccentBg)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: Radius.element,
                bottomTrailingRadius: Radius.element
            )
        )
    }

    // Gray strip with purple border
    private var addPurchasePriceStrip: some View {
        Button(action: { onAddPurchasePriceTap?() }) {
            HStack(alignment: .top, spacing: Spacing.l) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.textPrimary)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Add Purchase Price")
                        .font(Typography.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    Text("to view how your money performed over the years")
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.top, Spacing.xxxl)
            .padding(.bottom, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceLowContrast)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: Radius.element,
                    bottomTrailingRadius: Radius.element
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: Radius.element,
                    bottomTrailingRadius: Radius.element
                )
                .stroke(Color.purpleLight, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
