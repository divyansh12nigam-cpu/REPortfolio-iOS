import SwiftUI

struct AddPropertyStep1View: View {
    @Binding var formState: OnboardingFormState

    private var localitySuggestions: [String] {
        LocationData.localitiesFor(formState.city)
    }

    private var societySuggestions: [String] {
        LocationData.societiesFor(formState.locality)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxxxl) {
            Text("Where is your property located?")
                .font(Typography.bodyLarge)
                .foregroundColor(.textPrimary)

            AutoSuggestTextFieldView(
                label: "City",
                value: $formState.city,
                suggestions: LocationData.cities,
                placeholder: "e.g. Ghaziabad",
                onSuggestionSelected: { city in
                    formState.city = city
                    formState.locality = ""
                }
            )

            AutoSuggestTextFieldView(
                label: "Locality",
                value: $formState.locality,
                suggestions: localitySuggestions,
                placeholder: "e.g. Raj Nagar Extension"
            )

            AutoSuggestTextFieldView(
                label: "Apartment / Society",
                value: $formState.societyName,
                suggestions: societySuggestions,
                placeholder: "e.g. ATS Pious Headaways"
            )

            ChipSelectorView(
                label: "Select your floor plan",
                options: FloorPlan.allCases,
                selectedOption: formState.floorPlan,
                onOptionSelected: { formState.floorPlan = $0 },
                optionLabel: { $0.rawValue }
            )

            FormTextFieldView(
                label: "Area (sq.ft)",
                value: $formState.areaSqft,
                placeholder: "e.g. 1370",
                keyboardType: .numberPad
            )

            Spacer().frame(height: Spacing.widgetsM)
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.top, Spacing.widgetsXs)
    }
}
