import SwiftUI

@main
struct REPortfolioApp: App {
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
    }
}

enum AppScreen: Equatable {
    case portfolio
    case propertyDetail(index: Int)
    case addProperty
    case editProperty(index: Int)
}

struct RootNavigationView: View {
    @StateObject private var repository = PropertyRepository.shared
    @State private var activeScreen: AppScreen = .portfolio

    var body: some View {
        ZStack {
            PortfolioSummaryView(
                onPropertyTap: { index in activeScreen = .propertyDetail(index: index) },
                onAddClick: { activeScreen = .addProperty },
                onEditProperty: { index in activeScreen = .editProperty(index: index) }
            )

            if case .propertyDetail(let index) = activeScreen {
                PropertyDetailView(
                    onBack: { activeScreen = .portfolio },
                    detail: SamplePortfolioData.propertyDetail(
                        for: repository.propertyInputs,
                        at: index
                    )
                )
                .swipeBack(onBack: { activeScreen = .portfolio })
                .transition(.move(edge: .trailing))
            }

            if activeScreen == .addProperty {
                AddPropertyScreen(
                    onComplete: { activeScreen = .portfolio },
                    onBack: { activeScreen = .portfolio }
                )
                .swipeBack(onBack: { activeScreen = .portfolio })
                .transition(.move(edge: .trailing))
            }

            if case .editProperty(let index) = activeScreen {
                AddPropertyScreen(
                    onComplete: { activeScreen = .portfolio },
                    onBack: { activeScreen = .portfolio },
                    editingIndex: index,
                    initialFormState: repository.propertyInputs.indices.contains(index)
                        ? repository.propertyInputs[index].toFormState()
                        : nil
                )
                .swipeBack(onBack: { activeScreen = .portfolio })
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: activeScreen)
    }
}

#Preview {
    RootNavigationView()
}
