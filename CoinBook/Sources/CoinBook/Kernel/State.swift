import Foundation

struct State {
    var orderBook = OrderBook()
    var trades = [Trade]()
    struct OrderBook {
        var buys = [Order]()
        var sells = [Order]()
    }
    struct Order {
        var price: Price
        var quantity: Int64
    }
    struct Trade {
        var price: Price
        var quantity: Int64
//        var time: Date
    }
    typealias Price = Double
}
