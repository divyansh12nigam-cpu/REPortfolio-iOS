import SwiftUI

struct StickyBottomButtonsView: View {
    var onContact: () -> Void = {}
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

            // "Contact RE" filled button
            Button(action: onContact) {
                Text("Contact RE")
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
    StickyBottomButtonsView()
}
