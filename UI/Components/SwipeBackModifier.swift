import SwiftUI

/// Adds a native-feeling swipe-from-left-edge-to-go-back gesture.
/// The overlay screen interactively tracks the finger, then either
/// commits (slides off-screen and calls `onBack`) or cancels (springs back).
///
/// Usage: `.swipeBack(onBack: { activeScreen = .portfolio })`
struct SwipeBackModifier: ViewModifier {
    let onBack: () -> Void

    @State private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: dragOffset)
                .overlay(alignment: .leading) {
                    // Invisible 24pt hit area along the left edge for the drag gesture.
                    // Taps pass through (DragGesture minimumDistance = 10).
                    Color.clear
                        .frame(width: 24)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .global)
                                .onChanged { value in
                                    let dx = value.translation.width
                                    if dx > 0 {
                                        dragOffset = dx
                                    }
                                }
                                .onEnded { value in
                                    let threshold = geo.size.width * 0.35
                                    let predicted = value.predictedEndTranslation.width

                                    if dragOffset > threshold || predicted > geo.size.width * 0.5 {
                                        // Commit — animate off-screen, then remove the view silently
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            dragOffset = geo.size.width
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                            // Suppress the ZStack transition so the view
                                            // is removed instantly (it's already off-screen).
                                            var t = Transaction()
                                            t.disablesAnimations = true
                                            withTransaction(t) {
                                                onBack()
                                            }
                                        }
                                    } else {
                                        // Cancel — spring back to original position
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
        }
    }
}

extension View {
    func swipeBack(onBack: @escaping () -> Void) -> some View {
        modifier(SwipeBackModifier(onBack: onBack))
    }
}
