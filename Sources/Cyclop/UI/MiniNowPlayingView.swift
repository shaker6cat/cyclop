import AppKit
import SwiftUI

/// The folded state of the notch: a small cover on the left and a colourful
/// animated pulse on the right, like the compact Now Playing island on iPhone.
/// It uses Now Playing metadata only; it is deliberately not an audio capture
/// or spectrum analyser.
struct MiniNowPlayingView: View {
    let artwork: NSImage?
    let isPlaying: Bool

    @State private var pulse = false

    private let low: [CGFloat] = [4, 7, 5, 10, 6, 8, 4]
    private let high: [CGFloat] = [8, 12, 10, 18, 11, 14, 7]

    var body: some View {
        HStack(spacing: 0) {
            if let artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Theme.surfaceHover)
                    .frame(width: 24, height: 24)
                    .overlay(Image(systemName: "music.note").font(.system(size: 11)))
            }

            Spacer(minLength: 0)

            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<low.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.pink.opacity(0.95), .orange.opacity(0.75)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 3, height: pulse && isPlaying ? high[index] : low[index])
                        .animation(
                            isPlaying
                                ? .easeInOut(duration: 0.48)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.07)
                                : .easeOut(duration: 0.2),
                            value: pulse
                        )
                }
            }
            .frame(height: 20, alignment: .center)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { pulse = isPlaying }
        .onChange(of: isPlaying) { _, playing in pulse = playing }
    }
}
