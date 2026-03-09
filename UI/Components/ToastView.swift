import SwiftUI

/// Floating pill-shaped toast notification with icon and message.
/// Auto-dismiss and animation are handled by the parent view.
struct ToastView: View {
    let message: String
    var icon: String = "checkmark.circle.fill"
    var iconColor: Color = .successGreen

    var body: some View {
        HStack(spacing: Spacing.l) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(iconColor)
            Text(message)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.vertical, Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Radius.full)
                .fill(Color.surfaceWhite)
                .shadow(
                    color: .shadowNeutralLow,
                    radius: Elevation.cardShadow,
                    x: 0,
                    y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.full)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: Spacing.xxl) {
        ToastView(message: "Valuation updated for Flat in DLF Phase 5")
        ToastView(message: "All valuations updated")
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
