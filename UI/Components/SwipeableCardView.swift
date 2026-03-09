import SwiftUI

/// A wrapper that adds swipe-left (Edit + Delete) and swipe-right (Refresh) actions behind any card content.
struct SwipeableCardView<Content: View>: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onRefresh: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var openSide: OpenSide = .none
    @State private var dragDirection: DragDirection = .undecided
    @State private var cardHeight: CGFloat = 0

    private let buttonSize: CGFloat = 56
    private var trailingRevealWidth: CGFloat { buttonSize * 2 + Spacing.l * 2 }
    private var leadingRevealWidth: CGFloat { buttonSize + Spacing.l }
    private let snapThreshold: CGFloat = 0.4

    private enum OpenSide {
        case none, leading, trailing
    }

    private enum DragDirection {
        case undecided, horizontal, vertical
    }

    var body: some View {
        ZStack {
            // Trailing actions (swipe left → Edit + Delete)
            if offset < 0 {
                HStack(spacing: Spacing.l) {
                    Spacer()
                    Button(action: {
                        close()
                        onEdit()
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.surfaceWhite)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.brandPrimary)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        close()
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.surfaceWhite)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.errorRed)
                            .clipShape(Circle())
                    }
                }
                .padding(.leading, Spacing.l)
            }

            // Leading action (swipe right → Refresh)
            if offset > 0 && onRefresh != nil {
                HStack(spacing: 0) {
                    Button(action: {
                        close()
                        onRefresh?()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.surfaceWhite)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(Color.successGreen)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.trailing, Spacing.l)
            }

            // Card content on top
            content()
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: CardHeightPreferenceKey.self, value: geo.size.height)
                    }
                )
                .onPreferenceChange(CardHeightPreferenceKey.self) { cardHeight = $0 }
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            // Lock direction on first significant movement
                            if dragDirection == .undecided {
                                let absH = abs(value.translation.width)
                                let absV = abs(value.translation.height)
                                if absH > absV {
                                    dragDirection = .horizontal
                                } else {
                                    dragDirection = .vertical
                                }
                            }
                            // If vertical, do nothing — let ScrollView handle it
                            guard dragDirection == .horizontal else { return }

                            let translation = value.translation.width
                            switch openSide {
                            case .none:
                                if translation > 0 && onRefresh != nil {
                                    offset = min(leadingRevealWidth, translation)
                                } else {
                                    offset = max(-trailingRevealWidth, min(0, translation))
                                }
                            case .trailing:
                                let newOffset = -trailingRevealWidth + translation
                                offset = min(0, max(-trailingRevealWidth, newOffset))
                            case .leading:
                                let newOffset = leadingRevealWidth + translation
                                offset = max(0, min(leadingRevealWidth, newOffset))
                            }
                        }
                        .onEnded { value in
                            defer { dragDirection = .undecided }
                            guard dragDirection == .horizontal else { return }

                            let translation = value.translation.width
                            switch openSide {
                            case .none:
                                if translation > 0 && onRefresh != nil {
                                    if translation > leadingRevealWidth * snapThreshold {
                                        openLeading()
                                    } else {
                                        close()
                                    }
                                } else {
                                    if -translation > trailingRevealWidth * snapThreshold {
                                        openTrailing()
                                    } else {
                                        close()
                                    }
                                }
                            case .trailing:
                                if translation > trailingRevealWidth * snapThreshold {
                                    close()
                                } else {
                                    openTrailing()
                                }
                            case .leading:
                                if -translation > leadingRevealWidth * snapThreshold {
                                    close()
                                } else {
                                    openLeading()
                                }
                            }
                        }
                )
                .onTapGesture {
                    if openSide != .none { close() }
                }
        }
    }

    private func openTrailing() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = -trailingRevealWidth
            openSide = .trailing
        }
    }

    private func openLeading() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = leadingRevealWidth
            openSide = .leading
        }
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = 0
            openSide = .none
        }
    }
}

private struct CardHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
