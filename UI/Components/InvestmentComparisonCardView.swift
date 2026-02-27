import SwiftUI

struct InvestmentComparisonCardView: View {
    let detail: PropertyDetail

    // Illustration assets — replace with bundled images before shipping (URLs expire in 7 days)
    private let houseImg = "https://www.figma.com/api/mcp/asset/4a84a013-c012-45dd-82ac-e70c3be3621f"
    private let goldImg  = "https://www.figma.com/api/mcp/asset/b228abc4-39d6-4288-96b1-81664d99c7fb"
    private let niftyImg = "https://www.figma.com/api/mcp/asset/53286dc1-edbe-45b9-a216-cdef2cf688de"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Card title (two-line, both semibold textPrimary)
            VStack(alignment: .leading, spacing: 0) {
                Text("If \(detail.comparisonInvested) was invested in \(detail.comparisonYear):")
                    .font(Typography.bodySmall)
                    .foregroundColor(.textPrimary)
                Text("Property vs Gold vs Equity")
                    .font(Typography.bodyLarge)
                    .foregroundColor(.textPrimary)
            }

            // Warm beige container with 3 columns
            HStack(alignment: .top, spacing: Spacing.s) {
                // ── Your Property — white elevated card ──────────────
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    // Top group: illustration + label + divider
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: URL(string: houseImg)) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 65, height: 38)

                            // 🎉 floating badge — anchored to image top-right
                            Text("🎉")
                                .font(Typography.bodyMedium)
                                .frame(width: 30, height: 30)
                                .background(Color.insightAccentBg)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 4)
                                .offset(x: 20, y: -16)
                        }

                        Text("Your Property")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)

                        Divider().overlay(Color.borderSubtle)
                    }

                    // Bottom group: percentage + years
                    VStack(alignment: .leading, spacing: 0) {
                        Text(detail.propertyReturn)
                            .font(Typography.priceLabel)
                            .tracking(-0.4)
                            .foregroundColor(.textPrimary)
                        Text(detail.yearsLabel)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textDisabled)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xxxl)
                .frame(width: 135)
                .background(Color.surfaceWhite)
                .clipShape(RoundedRectangle(cornerRadius: Radius.element))
                .shadow(color: .shadowNeutralLow, radius: Elevation.cardShadow, x: 0, y: 1)

                // ── Gold — transparent on beige ─────────────────────
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        AsyncImage(url: URL(string: goldImg)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 65, height: 38)

                        Text("Gold")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)

                        Divider().overlay(Color.borderSubtle)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(detail.goldReturn)
                            .font(Typography.priceLabel)
                            .tracking(-0.4)
                            .foregroundColor(.textPrimary)
                        Text(detail.yearsLabel)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textDisabled)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xxxl)
                .frame(maxWidth: .infinity, alignment: .leading)

                // ── Nifty 50 — transparent on beige ─────────────────
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        AsyncImage(url: URL(string: niftyImg)) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 53, height: 38)

                        Text("Nifty 50")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)

                        Divider().overlay(Color.borderSubtle)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text(detail.niftyReturn)
                            .font(Typography.priceLabel)
                            .tracking(-0.4)
                            .foregroundColor(.textPrimary)
                        Text(detail.yearsLabel)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textDisabled)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xxxl)
                .frame(width: 95, alignment: .leading)
            }
            .padding(Spacing.s)
            .background(Color.surfaceAccentBase)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
        }
    }
}

#Preview {
    InvestmentComparisonCardView(detail: SamplePortfolioData.propertyDetail)
        .padding(.horizontal, Spacing.xxxl)
}
