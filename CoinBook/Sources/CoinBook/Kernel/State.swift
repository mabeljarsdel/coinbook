import Foundation

struct State {
    var orderBook = OrderBook()
    /// 30 trade items.
    /// Sorted in ascending ordered
    var trades = [Trade]()
    struct OrderBook {
        /// Ascending ordered 20 buy items.
        /// For UI display, you are supposed to reverse this list.
        var buys = [Order]()
        /// Ascending ordered 20 sell items.
        var sells = [Order]()
    }
    struct Order: Equatable {
        var price: Price
        var quantity: Int64
    }
    struct Trade: Equatable {
        var id: String
        var price: Price
        var quantity: Int64
        var side: TradeSide?
        var time: Date
    }
    enum TradeSide: String, Codable {
        case buy = "Buy", sell = "Sell"
    }
    typealias Price = Double
}
