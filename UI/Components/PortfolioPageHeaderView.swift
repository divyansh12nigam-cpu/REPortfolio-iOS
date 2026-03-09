import SwiftUI

struct PortfolioPageHeaderView: View {
    var title: String = "My Portfolio"
    var showRightButton: Bool = true
    /// When true (root/portfolio screen), shows a profile icon instead of back arrow.
    var isRootScreen: Bool = false
    var onBack: () -> Void = {}

    var body: some View {
        HStack {
            // Left button — profile icon on root, back arrow on sub-screens
            Button(action: onBack) {
                Image(systemName: isRootScreen ? "person.crop.circle" : "arrow.left")
                    .font(.system(size: isRootScreen ? 22 : 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(Color.borderSubtle, lineWidth: isRootScreen ? 0 : 1)
                    )
            }

            Spacer()

            Text(title)
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)

            Spacer()

            // Right button — search (portfolio list) or invisible spacer (detail)
            if showRightButton {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle().stroke(Color.borderSubtle, lineWidth: 1)
                        )
                }
            } else {
                // Invisible spacer to keep title centered
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceWhite.opacity(0.86))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.borderSubtle),
            alignment: .bottom
        )
    }
}

#Preview {
    PortfolioPageHeaderView()
        .padding()
}
