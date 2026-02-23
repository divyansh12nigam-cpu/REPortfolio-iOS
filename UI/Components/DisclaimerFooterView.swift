import SwiftUI

struct DisclaimerFooterView: View {
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xl) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)

            Text("Your portfolio data is private and encrypted. RE protects all sensitive financial information and never shares it with third parties without your consent.")
                .font(Typography.bodyMediumThin)
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceAccentBase)
    }
}

#Preview {
    DisclaimerFooterView()
}
