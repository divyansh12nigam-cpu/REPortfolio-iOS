import SwiftUI

struct AddPropertyStep2View: View {
    @Binding var formState: OnboardingFormState

    private var propertyDescription: String {
        var parts: [String] = []
        if let fp = formState.floorPlan { parts.append("\(fp.rawValue) Apartment") }
        if !formState.areaSqft.isEmpty { parts.append("\(formState.areaSqft) sq.ft") }
        return parts.joined(separator: ", ").isEmpty ? "Your Property" : parts.joined(separator: ", ")
    }

    private var autoName: String {
        var result = ""
        if let fp = formState.floorPlan { result += "\(fp.rawValue) " }
        let location = formState.societyName.isEmpty ? formState.locality : formState.societyName
        if !location.isEmpty { result += "in \(location)" }
        return result.isEmpty ? "My Property" : result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxxxl) {
            Text("Creating for")
                .font(Typography.bodyMedium)
                .foregroundColor(.textPrimary)

            PropertyPreviewCardView(
                propertyName: propertyDescription,
                societyName: formState.societyName.isEmpty ? formState.locality : formState.societyName
            )

            ChipSelectorView(
                label: "You are using this property as",
                options: PropertyUsageType.allCases,
                selectedOption: formState.usageType,
                onOptionSelected: { formState.usageType = $0 },
                optionLabel: { $0.rawValue }
            )

            if formState.usageType != nil {
                VStack(alignment: .leading, spacing: Spacing.xxxxl) {
                    FormTextFieldView(
                        label: "What price did you buy this property for?",
                        value: $formState.purchasePrice,
                        placeholder: "Invested value",
                        prefix: "₹",
                        keyboardType: .numberPad
                    )

                    FormTextFieldView(
                        label: "When did you buy this property?",
                        value: $formState.purchaseYear,
                        placeholder: "Year (e.g. 2018)",
                        keyboardType: .numberPad
                    )

                    if formState.usageType == .rentLease {
                        FormTextFieldView(
                            label: "Monthly rent you receive",
                            value: $formState.monthlyRent,
                            placeholder: "e.g. 25000",
                            prefix: "₹",
                            keyboardType: .numberPad
                        )
                    }

                    FormTextFieldView(
                        label: "Customise name of your property",
                        value: $formState.customName,
                        placeholder: "Custom name",
                        helperText: "It is currently named as \(autoName)"
                    )

                    Spacer().frame(height: Spacing.widgetsM)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut, value: formState.usageType)
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.widgetsXs)
    }
}
