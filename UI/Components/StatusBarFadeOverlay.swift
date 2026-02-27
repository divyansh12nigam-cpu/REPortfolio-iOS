import SwiftUI

/// A gradient overlay that covers the status bar area, preventing scrolled content
/// from hard-overlapping the system clock/signal/battery indicators.
/// Place inside a `ZStack(alignment: .top)` above the scroll content.
struct StatusBarFadeOverlay: View {
    var color: Color = .surfaceWhite

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: color, location: 0),
                .init(color: color, location: 0.6),
                .init(color: color.opacity(0), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 95)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack(alignment: .top) {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<30) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(i % 2 == 0 ? Color.gray.opacity(0.1) : Color.clear)
                }
            }
        }
        StatusBarFadeOverlay()
    }
}
