import SwiftUI

/// A wrapper that adds swipe-left (Edit + Delete) and swipe-right (Refresh) actions behind any card content.
struct SwipeableCardView<Content: View>: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onRefresh: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var openSide: OpenSide = .none

    private let actionWidth: CGFloat = 80
    private var trailingRevealWidth: CGFloat { actionWidth * 2 }  // Edit + Delete
    private var leadingRevealWidth: CGFloat { actionWidth }        // Refresh only
    private let snapThreshold: CGFloat = 0.4

    private enum OpenSide {
        case none, leading, trailing
    }

    var body: some View {
        ZStack {
            // Trailing actions (swipe left → Edit + Delete)
            if offset < 0 {
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        close()
                        onEdit()
                    }) {
                        VStack(spacing: Spacing.s) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20, weight: .medium))
                            Text("Edit")
                                .font(Typography.captionMed)
                        }
                        .foregroundColor(.surfaceWhite)
                        .frame(width: actionWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color.brandPrimary)
                    }

                    Button(action: {
                        close()
                        onDelete()
                    }) {
                        VStack(spacing: Spacing.s) {
                            Image(systemName: "trash")
                                .font(.system(size: 20, weight: .medium))
                            Text("Delete")
                                .font(Typography.captionMed)
                        }
                        .foregroundColor(.surfaceWhite)
                        .frame(width: actionWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color.errorRed)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }

            // Leading action (swipe right → Refresh)
            if offset > 0 && onRefresh != nil {
                HStack(spacing: 0) {
                    Button(action: {
                        close()
                        onRefresh?()
                    }) {
                        VStack(spacing: Spacing.s) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .medium))
                            Text("Refresh")
                                .font(Typography.captionMed)
                        }
                        .foregroundColor(.surfaceWhite)
                        .frame(width: actionWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color.successGreen)
                    }
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: Radius.card))
            }

            // Card content on top
            content()
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let translation = value.translation.width
                            switch openSide {
                            case .none:
                                if translation > 0 && onRefresh != nil {
                                    // Swiping right — cap at leading reveal width
                                    offset = min(leadingRevealWidth, translation)
                                } else {
                                    // Swiping left — cap at trailing reveal width
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
                            let translation = value.translation.width
                            switch openSide {
                            case .none:
                                if translation > 0 && onRefresh != nil {
                                    // Swiping right
                                    if translation > leadingRevealWidth * snapThreshold {
                                        openLeading()
                                    } else {
                                        close()
                                    }
                                } else {
                                    // Swiping left
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
