import SwiftUI

/// The visual envelope shared by compact and expanded notch states.
///
/// The shell owns the silhouette and clipping boundary. Its content is kept
/// in one coordinate space so expanding changes the envelope around it rather
/// than cross-fading two unrelated panels.
struct DynamicIslandShell<Content: View>: View {
    let isExpanded: Bool
    let bodySize: CGSize
    @ViewBuilder let content: () -> Content

    private var expandedWidth: CGFloat {
        bodySize.width + (isExpanded ? 2 * Theme.openTopRadius : 0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            silhouette
            content()
                .frame(width: bodySize.width, height: bodySize.height, alignment: .top)
                .clipped()
        }
        // The top edge remains the anchor. The window can grow downwards while
        // SwiftUI changes the width of the envelope around the same centre.
        .frame(width: expandedWidth, height: bodySize.height, alignment: .top)
        .animation(Theme.dynamicIslandAnimation, value: isExpanded)
        .animation(Theme.dynamicIslandSizeAnimation, value: bodySize)
    }

    @ViewBuilder
    private var silhouette: some View {
        if isExpanded {
            NotchShape(
                topRadius: Theme.openTopRadius,
                bottomRadius: Theme.openBottomRadius
            )
            .fill(Color.black)
            .frame(width: expandedWidth, height: bodySize.height)
            .shadow(color: .black.opacity(0.5), radius: 18, y: 8)
        } else {
            Capsule(style: .continuous)
                .fill(Color.black)
                .frame(width: bodySize.width, height: bodySize.height)
        }
    }
}
