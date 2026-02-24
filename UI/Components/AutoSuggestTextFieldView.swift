import SwiftUI

/// Text field with auto-suggest dropdown. Filters suggestions as user types.
struct AutoSuggestTextFieldView: View {
    let label: String
    @Binding var value: String
    let suggestions: [String]
    var placeholder: String = ""
    var onSuggestionSelected: ((String) -> Void)? = nil

    @FocusState private var isFocused: Bool

    private var filtered: [String] {
        if value.isEmpty { return suggestions }
        return suggestions.filter {
            $0.localizedCaseInsensitiveContains(value) &&
            $0.caseInsensitiveCompare(value) != .orderedSame
        }
    }

    private var showDropdown: Bool {
        isFocused && !filtered.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)

            TextField(placeholder, text: $value)
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)
                .focused($isFocused)
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, Spacing.xl)
                .overlay(
                    RoundedRectangle(cornerRadius: showDropdown ? 0 : Radius.sm)
                        .stroke(Color.formFieldBorder, lineWidth: 1)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: showDropdown
                        ? 0 // top corners handled by UnevenRoundedRectangle below
                        : Radius.sm)
                )
                .padding(.top, Spacing.l)

            if showDropdown {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered, id: \.self) { suggestion in
                            Button {
                                if let handler = onSuggestionSelected {
                                    handler(suggestion)
                                } else {
                                    value = suggestion
                                }
                                isFocused = false
                            } label: {
                                Text(suggestion)
                                    .font(Typography.bodyMedium)
                                    .foregroundColor(.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, Spacing.xxl)
                                    .padding(.vertical, Spacing.xl)
                            }
                            if suggestion != filtered.last {
                                Divider().foregroundColor(.formFieldBorder)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.surfaceWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.formFieldBorder, lineWidth: 1)
                )
            }
        }
    }
}
