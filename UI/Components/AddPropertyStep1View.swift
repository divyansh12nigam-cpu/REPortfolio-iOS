import SwiftUI

struct AddPropertyStep1View: View {
    @Binding var formState: OnboardingFormState

    private var localitySuggestions: [String] {
        ProjectDirectoryService.localitiesFor(formState.city)
    }

    private var societySuggestions: [String] {
        ProjectDirectoryService.allSocietiesFor(city: formState.city)
    }

    private var areaOptions: [Int] {
        guard !formState.societyName.isEmpty,
              let fp = formState.floorPlan,
              let areas = ProjectDirectoryService.areasFor(
                  society: formState.societyName,
                  floorPlan: fp,
                  city: formState.city
              ) else { return [] }
        return areas
    }

    private var floorPlanOptions: [FloorPlan] {
        if !formState.societyName.isEmpty,
           let configs = ProjectDirectoryService.configurationsFor(
               society: formState.societyName,
               locality: formState.locality,
               city: formState.city
           ) {
            return configs
        }
        return Array(FloorPlan.allCases)
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
                label: "Apartment / Society",
                value: $formState.societyName,
                suggestions: societySuggestions,
                placeholder: "e.g. ATS Knightsbridge",
                onSuggestionSelected: { society in
                    formState.societyName = society
                    formState.areaSqft = ""  // Reset area when society changes
                    // Auto-fill locality from reverse lookup
                    if let loc = ProjectDirectoryService.localityFor(society: society, city: formState.city) {
                        formState.locality = loc
                    }
                    // Reset floor plan if current selection isn't available for new society
                    if let configs = ProjectDirectoryService.configurationsFor(
                        society: society,
                        locality: formState.locality,
                        city: formState.city
                    ), let current = formState.floorPlan, !configs.contains(current) {
                        formState.floorPlan = nil
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
                }
            )

            ChipSelectorView(
                label: "Select your floor plan",
                options: floorPlanOptions,
                selectedOption: formState.floorPlan,
                onOptionSelected: {
                    formState.floorPlan = $0
                    formState.areaSqft = ""  // Reset area when BHK changes
                },
                optionLabel: { $0.rawValue }
            )

            if !areaOptions.isEmpty {
                ChipSelectorView(
                    label: "Select area (sq.ft)",
                    options: areaOptions,
                    selectedOption: Int(formState.areaSqft),
                    onOptionSelected: { formState.areaSqft = String($0) },
                    optionLabel: { "\($0) sq.ft" }
                )
            }

            FormTextFieldView(
                label: areaOptions.isEmpty ? "Area (sq.ft)" : "Or enter area manually",
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
