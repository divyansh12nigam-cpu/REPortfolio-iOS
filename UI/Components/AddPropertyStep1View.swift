import SwiftUI

struct AddPropertyStep1View: View {
    @Binding var formState: OnboardingFormState

    private var localitySuggestions: [String] {
        ProjectDirectoryService.localitiesFor(formState.city)
    }

    private var societySuggestions: [String] {
        ProjectDirectoryService.societiesFor(
            locality: formState.locality,
            city: formState.city
        )
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
                    formState.societyName = ""
                    // Load dynamic directory for the selected city
                    Task {
                        await ProjectDirectoryService.loadDirectory(for: city)
                    }
                }
            )

            AutoSuggestTextFieldView(
                label: "Locality",
                value: $formState.locality,
                suggestions: localitySuggestions,
                placeholder: "e.g. Sector 150",
                onSuggestionSelected: { locality in
                    formState.locality = locality
                    formState.societyName = ""  // Reset society when locality changes
                }
            )

            AutoSuggestTextFieldView(
                label: "Apartment / Society",
                value: $formState.societyName,
                suggestions: societySuggestions,
                placeholder: "e.g. ATS Knightsbridge"
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
        .task {
            // Pre-load directory for current city (covers edit mode)
            if !formState.city.isEmpty {
                await ProjectDirectoryService.loadDirectory(for: formState.city)
            }
        }
    }
}
