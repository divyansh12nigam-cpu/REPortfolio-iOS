import SwiftUI

/// A wrapper that adds swipe-left-to-reveal Edit + Delete actions behind any card content.
struct SwipeableCardView<Content: View>: View {
    let onEdit: () -> Void
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false

    private let actionWidth: CGFloat = 80
    private var revealWidth: CGFloat { actionWidth * 2 }
    private let snapThreshold: CGFloat = 0.4

    var body: some View {
        ZStack(alignment: .trailing) {
            // Action buttons (behind card) — only rendered when swiping
            if offset < 0 {
            HStack(spacing: 0) {
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

            // Card content on top
            content()
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let translation = value.translation.width
                            if isOpen {
                                // Already open — allow dragging back closed or further
                                let newOffset = -revealWidth + translation
                                offset = min(0, max(-revealWidth, newOffset))
                            } else {
                                // Only allow left-swipe (negative)
                                offset = min(0, translation)
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.width
                            if isOpen {
                                // If dragged right past threshold, close
                                if translation > revealWidth * snapThreshold {
                                    close()
                                } else {
                                    open()
                                }
                            } else {
                                // If dragged left past threshold, open
                                if -translation > revealWidth * snapThreshold {
                                    open()
                                } else {
                                    close()
                                }
                            }
                        }
                )
                .onTapGesture {
                    if isOpen { close() }
                }
        }
    }

    private func open() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = -revealWidth
            isOpen = true
        }
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.25)) {
            offset = 0
            isOpen = false
        }
    }
}
