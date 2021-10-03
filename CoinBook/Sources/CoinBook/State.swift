import Foundation

struct State {
    var orders = [Order]()
    var trades = [Trade]()
    struct Order {
        
    }
    struct Trade {
        
    }
}


/// User command/intention.
/// This is empty now as this app does not have controllable UI.
enum Action {
}

enum Rendition {
    case state(State)
}
struct DataRendition {
    var orderBook: OrderBook
    struct OrderBook {
        var items = [Item]()
        struct Item {
            var price: Double
            var quantity: Double
            var total: Double
        }
    }
    var recentTrade: RecentTrade
    struct RecentTrade {
        var items = [Item]()
        struct Item {
            var price: Double
            var quantity: Double
            var time: Date
        }
    }
}

