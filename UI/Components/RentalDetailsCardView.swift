import SwiftUI

struct RentalDetailsCardView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(spacing: 0) {
            // ── Main bordered card (top rounded corners) ──────────────
            VStack(spacing: Spacing.xxxl) {
                // Header: RENTAL DETAILS + "As added by you" + 3-dot menu
                VStack(alignment: .leading, spacing: Spacing.widgetsXs) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("RENTAL DETAILS")
                                .font(Typography.overline)
                                .tracking(0.88)
                                .foregroundColor(.textPrimary)
                            Text("As added by you")
                                .font(Typography.bodySmallThin)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .frame(width: 36, height: 36)
                    }

                    // 3-column stats with vertical dividers
                    HStack(alignment: .top, spacing: 0) {
                        // Monthly Rental
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(detail.monthlyRental)
                                .font(Typography.bodyLarge)
                                .foregroundColor(.textPrimary)
                            Text("Monthly Rental")
                                .font(Typography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Vertical divider
                        Rectangle()
                            .fill(Color.borderSubtle)
                            .frame(width: 1, height: 42)
                            .padding(.horizontal, Spacing.xs)

                        // Annual Rental
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(detail.annualRentalDetail)
                                .font(Typography.bodyLarge)
                                .foregroundColor(.textPrimary)
                            Text("Annual Rental")
                                .font(Typography.bodySmall)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.leading, Spacing.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Vertical divider
                        Rectangle()
                            .fill(Color.borderSubtle)
                            .frame(width: 1, height: 42)
                            .padding(.horizontal, Spacing.xs)

                        // Rental Yield
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(detail.rentalYield)
                                .font(Typography.bodyLarge)
                                .foregroundColor(.textGreen)
                            HStack(spacing: 2) {
                                Text("Rental Yield")
                                    .font(Typography.bodySmall)
                                    .foregroundColor(.textSecondary)
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.leading, Spacing.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // ── Scheduled Reminder sub-card ──────────────────
                VStack(spacing: Spacing.xl) {
                    // Header: bell + overline + pencil
                    HStack {
                        HStack(spacing: Spacing.s) {
                            Image(systemName: "bell")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                            Text("SCHEDULED REMINDER")
                                .font(Typography.overline)
                                .tracking(0.88)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .frame(width: 28, height: 28)
                    }

                    // Rent due row
                    HStack {
                        Text("Rent due")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text(detail.rentDueDay)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)
                    }

                    Divider().overlay(Color.borderSubtle)

                    // Yearly lease renewal row
                    HStack {
                        Text("Yearly lease renewal")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text(detail.leaseRenewal)
                            .font(Typography.bodySmall)
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.leading, Spacing.xxl)
                .padding(.trailing, Spacing.l)
                .padding(.top, Spacing.l)
                .padding(.bottom, Spacing.xxl)
                .background(Color.surfaceLowContrast)
                .clipShape(RoundedRectangle(cornerRadius: Radius.element))
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.xxxxl)
            .padding(.bottom, Spacing.xxl)
            .background(Color.surfaceWhite)
            .clipShape(
                .rect(
                    topLeadingRadius: Radius.card,
                    topTrailingRadius: Radius.card
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: Radius.card,
                    topTrailingRadius: Radius.card
                )
                .stroke(Color.borderSubtle, lineWidth: 1)
            )

            // ── Insight strip at bottom (bottom rounded corners) ─────
            HStack(spacing: Spacing.l) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.insightSparkle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(detail.insightLoss)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text(detail.insightOpportunity)
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .frame(width: 28, height: 28)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.xl)
            .background(Color.surfaceWhite)
            .clipShape(
                .rect(
                    bottomLeadingRadius: Radius.element,
                    bottomTrailingRadius: Radius.element
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: Radius.element,
                    bottomTrailingRadius: Radius.element
                )
                .stroke(Color.borderSubtle, lineWidth: 1)
            )
        }
        .padding(.horizontal, Spacing.xxxl)
    }
}

#Preview {
    RentalDetailsCardView(detail: SamplePortfolioData.propertyDetail)
}
