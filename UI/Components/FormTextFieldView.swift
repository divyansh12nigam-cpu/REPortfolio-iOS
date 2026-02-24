import SwiftUI

struct FormTextFieldView: View {
    let label: String
    @Binding var value: String
    var placeholder: String = ""
    var prefix: String = ""
    var keyboardType: UIKeyboardType = .default
    var helperText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            Text(label)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.s) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                TextField(placeholder, text: $value)
                    .font(Typography.bodyMedium)
                    .foregroundColor(.textPrimary)
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.xl)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(Color.formFieldBorder, lineWidth: 1)
            )

            if !helperText.isEmpty {
                Text(helperText)
                    .font(Typography.bodySmallThin)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}
