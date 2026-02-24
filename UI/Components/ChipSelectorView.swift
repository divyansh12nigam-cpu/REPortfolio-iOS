import SwiftUI

struct ChipSelectorView<T: Hashable>: View {
    let label: String
    let options: [T]
    let selectedOption: T?
    let onOptionSelected: (T) -> Void
    let optionLabel: (T) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            Text(label)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.l) {
                ForEach(options, id: \.self) { option in
                    let isSelected = option == selectedOption
                    Button { onOptionSelected(option) } label: {
                        Text(optionLabel(option))
                            .font(Typography.bodyMedium)
                            .foregroundColor(isSelected ? .surfaceWhite : .textPrimary)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.l)
                            .background(isSelected ? Color.brandPrimary : Color.clear)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : Color.formFieldBorder, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}
