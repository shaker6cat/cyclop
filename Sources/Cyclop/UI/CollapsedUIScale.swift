import SwiftUI

private struct CollapsedUIScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

extension EnvironmentValues {
    var collapsedUIScale: CGFloat {
        get { self[CollapsedUIScaleKey.self] }
        set { self[CollapsedUIScaleKey.self] = newValue }
    }
}
