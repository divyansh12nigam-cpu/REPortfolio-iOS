import SwiftUI

@main
struct REPortfolioApp: App {
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
    }
}

struct RootNavigationView: View {
    @State private var showDetail = false

    var body: some View {
        ZStack {
            PortfolioSummaryView(onPropertyTap: { showDetail = true })

            if showDetail {
                PropertyDetailView(
                    onBack: { showDetail = false },
                    detail: SamplePortfolioData.propertyDetail
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: showDetail)
    }
}

#Preview {
    RootNavigationView()
}
