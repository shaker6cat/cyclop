import SwiftUI

/// The folded widgets share one small slot. A request first spins the current
/// face, then lands on the model's final face; this keeps the visual motion
/// continuous even though the two widgets have very different layouts.
struct CollapsedWheelView: View {
    let position: CGFloat
    let isSnapping: Bool
    let artwork: NSImage?
    let isPlaying: Bool
    let calendar: CalendarStore
    let hasMedia: Bool
    let faceHeight: CGFloat
    let scale: CGFloat

    init(
        position: CGFloat,
        isSnapping: Bool,
        artwork: NSImage?,
        isPlaying: Bool,
        calendar: CalendarStore,
        hasMedia: Bool,
        faceHeight: CGFloat,
        scale: CGFloat = 1
    ) {
        self.position = position
        self.isSnapping = isSnapping
        self.artwork = artwork
        self.isPlaying = isPlaying
        self.calendar = calendar
        self.hasMedia = hasMedia
        self.faceHeight = faceHeight
        self.scale = scale
    }

    var body: some View {
        let base = Int(floor(position))
        let fraction = position - CGFloat(base)
        VStack(spacing: 0) {
            face(for: base)
                .frame(maxWidth: .infinity, minHeight: faceHeight, maxHeight: faceHeight)
            face(for: base + 1)
                .frame(maxWidth: .infinity, minHeight: faceHeight, maxHeight: faceHeight)
        }
        .frame(height: faceHeight, alignment: .top)
        .frame(maxWidth: .infinity)
        .offset(y: -fraction * faceHeight)
        .animation(isSnapping ? .interpolatingSpring(stiffness: 220, damping: 25) : nil, value: position)
        .clipped()
    }

    @ViewBuilder
    private func face(for index: Int) -> some View {
        if index.isMultiple(of: 2), hasMedia {
            MiniNowPlayingView(artwork: artwork, isPlaying: isPlaying)
                .environment(\.collapsedUIScale, scale)
                .frame(height: faceHeight)
        } else {
            CalendarClockView(calendar: calendar)
                .environment(\.collapsedUIScale, scale)
                .frame(height: faceHeight)
        }
    }
}
