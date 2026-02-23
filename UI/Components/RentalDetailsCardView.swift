import SwiftUI

struct RentalDetailsCardView: View {
    let detail: PropertyDetail

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            // Section overline
            Text("RENTAL DETAILS")
                .font(Typography.overline)
                .tracking(0.88)
                .foregroundColor(.textSecondary)

            // Rent amount + yield row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Monthly Rental")
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                    Text(detail.monthlyRental)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Annual Rental")
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                    Text(detail.annualRentalDetail)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textPrimary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Rental Yield")
                        .font(Typography.bodySmallThin)
                        .foregroundColor(.textSecondary)
                    Text(detail.rentalYield)
                        .font(Typography.bodyLarge)
                        .foregroundColor(.textGreen)
                }
            }

            Divider().overlay(Color.borderSubtle)

            // Rent schedule
            VStack(alignment: .leading, spacing: Spacing.xl) {
                RentScheduleRow(label: "Rent Due", value: detail.rentDueDay)
                RentScheduleRow(label: "Lease Renewal", value: detail.leaseRenewal)
            }

            // Insight strips
            InsightStripView(
                text: detail.insightLoss,
                icon: "exclamationmark.circle",
                bgColor: .insightBaseLight
            )
            InsightStripView(
                text: detail.insightOpportunity,
                icon: "sparkles",
                bgColor: .purpleLight
            )
        }
        .padding(.horizontal, Spacing.xxxl)
    }
}

private struct RentScheduleRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(Typography.bodySmallThin)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(Typography.bodySmall)
                .foregroundColor(.textPrimary)
        }
    }
}

private struct InsightStripView: View {
    let text: String
    let icon: String
    let bgColor: Color

    var body: some View {
        HStack(spacing: Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.insightSparkle)
            Text(text)
                .font(Typography.bodySmallThin)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

#Preview {
    RentalDetailsCardView(detail: SamplePortfolioData.propertyDetail)
}
