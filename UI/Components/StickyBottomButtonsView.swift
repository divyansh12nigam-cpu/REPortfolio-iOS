import SwiftUI

struct StickyBottomButtonsView: View {
    var body: some View {
        VStack(spacing: Spacing.l) {
            // Primary CTA — blue filled capsule
            Button(action: {}) {
                Text("Post for Sale/Rent — FREE")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.surfaceWhite.opacity(0.96))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.brandPrimary)
                    .clipShape(Capsule())
            }

            // Secondary CTA — accent tinted capsule
            Button(action: {}) {
                Text("Find properties for investment")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.brandText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.insightAccentBg)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.xl)
        .padding(.bottom, Spacing.l)
    }
}

#Preview {
    StickyBottomButtonsView()
}
