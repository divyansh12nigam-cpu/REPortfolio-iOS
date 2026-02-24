import SwiftUI

struct DisclaimerFooterView: View {
    var body: some View {
        VStack(spacing: Spacing.l) {
            // Lock icon in a white circle with shadow
            ZStack {
                Circle()
                    .fill(Color.surfaceWhite)
                    .frame(width: 32, height: 32)
                    .shadow(color: .shadowNeutralLow, radius: 4, x: 0, y: 2)
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.textPrimary)
            }

            Text("Your details are private and visible only to you.")
                .font(Typography.bodyMediumThin)
                .foregroundColor(.textPrimary.opacity(0.93))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.xxxl)
        .padding(.bottom, Spacing.widgetsXs)
        .background(Color.surfaceAccentBase)
    }
}

#Preview {
    DisclaimerFooterView()
}
