import Foundation

/// User command/intention.
/// This is empty now as this app does not have controllable UI.
enum Action {
    case navigate(Location)
}

/// Temporary state describes how UI will be rendered.
/// This is ephemeral state generated only for rendering.
struct Rendition {
    /// Designates where to navigate.
    /// This can be `nil` to represent "no navigation".
    var location = Location?.none
    enum Location { case orderBook, recentTrades }
    var orderBook = OrderBook()
    struct OrderBook {
        var items = [State.Order]()
        var totals = [Double]()
    }
    var recentTrade = RecentTrade()
    struct RecentTrade {
        var items = [State.Trade]()
    }
}

enum Location {
    case orderBook
    case recentTrades
}
