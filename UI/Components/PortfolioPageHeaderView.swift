import SwiftUI

struct PortfolioPageHeaderView: View {
    var title: String = "My Portfolio"
    var showRightButton: Bool = true
    var onBack: () -> Void = {}

    var body: some View {
        HStack {
            // Back button — circular border
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(Color.borderSubtle, lineWidth: 1)
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
