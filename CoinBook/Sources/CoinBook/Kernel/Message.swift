import Foundation

/// User command/intention.
/// This is empty now as this app does not have controllable UI.
enum Action {
    case navigate(Location)
}

/// Temporary state describes how UI will be rendered.
/// This is ephemeral state generated only for rendering.
enum Rendition {
    /// Designates where to navigate.
    case navigate(Location)
    case state(State)
    /// Renders a warnging for some errors.
    case warning(Error)
}
extension Rendition {
    var state: State? {
        guard case let .state(x) = self else { return nil }
        return x
    }
}

enum Location {
    case orderBook
    case recentTrades
}
