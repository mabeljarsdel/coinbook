import Foundation

extension State.Order {
    static func from(bitMEX m: BitMEXChannel.OrderBookL2) -> State.Order {
        // TODO: Need to make a proper algorithm... No "-1".
        State.Order(
            price: m.price ?? -1,
            quantity: m.size ?? -1)
    }
}

extension State.Trade {
    static func from(bitMEX m: BitMEXChannel.Trade) -> State.Trade {
        // TODO: Need to make a proper algorithm... No `-1` or `.distantPast`.
        State.Trade(
            price: m.price ?? -1,
            quantity: m.size ?? -1,
            time: .distantPast)
    }
}
