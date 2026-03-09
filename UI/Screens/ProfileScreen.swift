import SwiftUI

struct ProfileScreen: View {
    var onBack: () -> Void = {}

    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        VStack(spacing: 0) {
            PortfolioPageHeaderView(
                title: "Profile",
                showRightButton: false,
                onBack: onBack
            )

            Spacer().frame(height: Spacing.widgetsM)

            // Account info
            VStack(spacing: Spacing.xxl) {
                // Avatar circle with initial
                let initial = authManager.currentUserEmail?.prefix(1).uppercased() ?? "?"
                Text(initial)
                    .font(Typography.priceLabel)
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())

                // Email
                Text(authManager.currentUserEmail ?? "—")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            // Sign out button
            Button(action: {
                Task { await authManager.signOut() }
            }) {
                HStack(spacing: Spacing.l) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                    Text("Sign Out")
                        .font(Typography.bodyLarge)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, Spacing.xxxl)
            .padding(.bottom, Spacing.widgetsM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfaceWhite)
    }
}

#Preview {
    ProfileScreen()
}
