import SwiftUI

@main
struct REPortfolioApp: App {
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.authState {
                case .loading:
                    // Splash / loading while checking Keychain session
                    VStack {
                        ProgressView()
                        Text("Loading...")
                            .font(Typography.bodySmall)
                            .foregroundColor(.textSecondary)
                            .padding(.top, Spacing.xxl)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.surfaceWhite)

                case .signedOut:
                    SignInScreen()

                case .signedIn:
                    RootNavigationView()
                }
            }
            .task {
                await authManager.checkSession()
            }
        }
    }
}

enum AppScreen: Equatable {
    case portfolio
    case profile
    case propertyDetail(index: Int)
    case addProperty
    case editProperty(index: Int)
    /// Edit flow opened from the "Add Purchase Price" card strip — jumps to Step 2, focuses purchase price.
    case editPropertyPurchasePrice(index: Int)
}

struct RootNavigationView: View {
    @StateObject private var repository = PropertyRepository.shared
    @State private var activeScreen: AppScreen = .portfolio
    @State private var hasSyncedFromCloud = false

    var body: some View {
        ZStack {
            PortfolioSummaryView(
                onPropertyTap: { index in activeScreen = .propertyDetail(index: index) },
                onAddClick: { activeScreen = .addProperty },
                onEditProperty: { index in activeScreen = .editProperty(index: index) },
                onAddPurchasePrice: { index in activeScreen = .editPropertyPurchasePrice(index: index) },
                onProfileTap: { activeScreen = .profile }
            )

            if activeScreen == .profile {
                ProfileScreen(onBack: { activeScreen = .portfolio })
                    .swipeBack(onBack: { activeScreen = .portfolio })
                    .transition(.move(edge: .leading))
            }

            if case .propertyDetail(let index) = activeScreen {
                PropertyDetailView(
                    onBack: { activeScreen = .portfolio },
                    detail: SamplePortfolioData.propertyDetail(
                        for: repository.propertyInputs,
                        at: index,
                        realValuations: repository.valuations.isEmpty ? nil : repository.valuations
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

            if case .editPropertyPurchasePrice(let index) = activeScreen {
                AddPropertyScreen(
                    onComplete: { activeScreen = .portfolio },
                    onBack: { activeScreen = .portfolio },
                    editingIndex: index,
                    initialFormState: repository.propertyInputs.indices.contains(index)
                        ? repository.propertyInputs[index].toFormState()
                        : nil,
                    startAtPurchasePrice: true
                )
                .swipeBack(onBack: { activeScreen = .portfolio })
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: activeScreen)
        .task {
            guard !hasSyncedFromCloud else { return }
            hasSyncedFromCloud = true
            await repository.syncFromCloud()
        }
    }
}

#Preview {
    RootNavigationView()
}
