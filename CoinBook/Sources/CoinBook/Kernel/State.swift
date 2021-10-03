import Foundation

struct State {
    private(set) var orders = [Order]()
    private(set) var trades = [Trade]()
    struct OrderBook {
        var buys = [Order]()
        var sells = [Order]()
    }
    struct Order {
        var price: Double
        var quantity: Int64
    }
    struct Trade {
        var price: Double
        var quantity: Int64
        var time: Date
    }
}
extension State {
    mutating func push(_ order:Order) {
        orders.append(order)
    }
    mutating func push(_ trade:Trade) {
        trades.append(trade)
    }
}
extension State {
    /// Produces a rendition values.
    /// As we limited number of maximum visible order to `20`, this can't be heavy load.
    func render() -> Rendition {
        Rendition(
            location: nil,
            orderBook: Rendition.OrderBook(
                items: orders,
                totals: orders.map { x in x.price }),
            recentTrade: Rendition.RecentTrade(
                items: trades
            ))
    }
}


