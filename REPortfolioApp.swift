import SwiftUI

@main
struct REPortfolioApp: App {
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
    }
}

enum AppScreen {
    case portfolio
    case propertyDetail
    case addProperty
}

struct RootNavigationView: View {
    @State private var activeScreen: AppScreen = .portfolio

    var body: some View {
        ZStack {
            PortfolioSummaryView(
                onPropertyTap: { activeScreen = .propertyDetail },
                onAddClick: { activeScreen = .addProperty }
            )

            if activeScreen == .propertyDetail {
                PropertyDetailView(
                    onBack: { activeScreen = .portfolio },
                    detail: SamplePortfolioData.propertyDetail
                )
                .transition(.move(edge: .trailing))
            }

            if activeScreen == .addProperty {
                AddPropertyScreen(
                    onComplete: { activeScreen = .portfolio },
                    onBack: { activeScreen = .portfolio }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: activeScreen)
    }
}

#Preview {
    RootNavigationView()
}
