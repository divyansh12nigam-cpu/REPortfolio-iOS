import SwiftUI

/// Mutable shared state holder for property inputs.
/// Seeded from SamplePortfolioData, allows adding new properties from the onboarding flow.
class PropertyRepository: ObservableObject {
    static let shared = PropertyRepository()

    @Published var propertyInputs: [PropertyInput]

    private init() {
        self.propertyInputs = SamplePortfolioData.propertyInputs
    }

    func addProperty(_ input: PropertyInput) {
        propertyInputs.append(input)
    }
}
