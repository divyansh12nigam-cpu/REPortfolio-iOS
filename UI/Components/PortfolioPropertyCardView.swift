import SwiftUI

// ─── Entry point — dispatches to variant ─────────────────────────────────────

struct PortfolioPropertyCardView: View {
    let property: PortfolioProperty
    var onClick: () -> Void = {}

    var body: some View {
        switch property.cardVariant {
        case .plain:            PlainCardView(property: property, onClick: onClick)
        case .insight:          InsightCardView(property: property, onClick: onClick)
        case .insightAction:    InsightActionCardView(property: property, onClick: onClick)
        case .addPurchasePrice: AddPurchasePriceCardView(property: property, onClick: onClick)
        }
    }
}

// ─── Shared card body ─────────────────────────────────────────────────────────

private struct CardBodyView: View {
    let property: PortfolioProperty
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Title row + status badge
            HStack {
                Text(property.title)
                    .font(Typography.titleSmall)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
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
                // Est. Value — mixed font sizes ("₹ 1.4 - 1.7" large + "Cr" small)
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

// ─── Variant 1: PLAIN ─────────────────────────────────────────────────────────

private struct PlainCardView: View {
    let property: PortfolioProperty
    let onClick: () -> Void
    var body: some View {
        CardBodyView(property: property, onClick: onClick)
    }
}

// ─── Variant 2: INSIGHT — white→purple gradient strip ────────────────────────

private struct InsightCardView: View {
    let property: PortfolioProperty
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CardBodyView(property: property, onClick: onClick)
                .zIndex(2)

            // Purple gradient strip — peeks Spacing.xxl behind the card
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
            .offset(y: -Spacing.xxl)   // pulls strip UP behind card
            .zIndex(1)
        }
    }
}

// ─── Variant 3: INSIGHT_ACTION — blue strip + "Post now" pill ────────────────

private struct InsightActionCardView: View {
    let property: PortfolioProperty
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CardBodyView(property: property, onClick: onClick)
                .zIndex(2)

            HStack(spacing: Spacing.xl) {
                Text(property.insightText)
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // White pill "Post now" button
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
            .offset(y: -Spacing.xxl)   // pulls strip UP behind card
            .zIndex(1)
        }
    }
}

// ─── Variant 4: ADD_PURCHASE_PRICE — gray + purple border strip ───────────────

private struct AddPurchasePriceCardView: View {
    let property: PortfolioProperty
    let onClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CardBodyView(property: property, onClick: onClick)
                .zIndex(2)

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
            .offset(y: -Spacing.l)   // pulls strip UP behind card
            .zIndex(1)
        }
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
