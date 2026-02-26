import SwiftUI

/// Mutable shared state holder for property inputs.
/// Seeded from SamplePortfolioData, allows adding new properties from the onboarding flow.
class PropertyRepository: ObservableObject {
    static let shared = PropertyRepository()

    private static let inputsKey = "savedPropertyInputs"
    private static let countKey = "savedAddedCount"

    @Published var propertyInputs: [PropertyInput]
    /// Number of user-added properties (inserted at the front of the list).
    @Published private(set) var addedCount: Int = 0

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.inputsKey),
           let saved = try? JSONDecoder().decode([PropertyInput].self, from: data) {
            self.propertyInputs = saved
            self.addedCount = UserDefaults.standard.integer(forKey: Self.countKey)
        } else {
            self.propertyInputs = SamplePortfolioData.propertyInputs
        }
    }

    func addProperty(_ input: PropertyInput) {
        propertyInputs.insert(input, at: 0)
        addedCount += 1
        save()
    }

    func removeProperty(at index: Int) {
        guard propertyInputs.indices.contains(index) else { return }
        propertyInputs.remove(at: index)
        if index < addedCount { addedCount -= 1 }
        save()
    }

    func updateProperty(at index: Int, with input: PropertyInput) {
        guard propertyInputs.indices.contains(index) else { return }
        propertyInputs[index] = input
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(propertyInputs) {
            UserDefaults.standard.set(data, forKey: Self.inputsKey)
        }
        UserDefaults.standard.set(addedCount, forKey: Self.countKey)
    }
}
