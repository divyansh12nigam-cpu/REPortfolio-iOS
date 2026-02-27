import SwiftUI

struct PropertyDetailBottomBarView: View {
    var onEditDetails: () -> Void = {}
    var onPostForSale: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.m) {
            // "Edit Details" ghost button with pencil icon
            Button(action: onEditDetails) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                    Text("Edit Details")
                        .font(Typography.bodyMedium)
                }
                .foregroundColor(.brandPrimary)
                .frame(height: 44)
                .padding(.horizontal, Spacing.xxxl)
                .overlay(
                    Capsule()
                        .stroke(Color.borderSubtle, lineWidth: 1)
                )
            }

            // "Post for Sell/Rent — Free" filled button
            Button(action: onPostForSale) {
                Text("Post for Sell/Rent — Free")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.surfaceWhite.opacity(0.96))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.brandPrimary)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xl)
        .background(
            Color.surfaceWhite
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: -4)
        )
    }
}

#Preview {
    PropertyDetailBottomBarView()
}
