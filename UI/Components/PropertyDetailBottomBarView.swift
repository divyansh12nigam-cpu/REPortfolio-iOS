import SwiftUI

struct PropertyDetailBottomBarView: View {
    var onSchedule: () -> Void = {}
    var onCompare: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.xl) {
            // "Compare" ghost button
            Button(action: onCompare) {
                Text("Compare")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.brandPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.element)
                            .stroke(Color.brandPrimary, lineWidth: 1)
                    )
            }

            // "Schedule Visit" filled button
            Button(action: onSchedule) {
                Text("Schedule Visit")
                    .font(Typography.bodyMedium)
                    .foregroundColor(.surfaceWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.brandPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.element))
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.xxl)
        .background(Color.surfaceWhite)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.borderSubtle)
            , alignment: .top
        )
    }
}

#Preview {
    PropertyDetailBottomBarView()
}
