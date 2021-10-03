import Foundation

struct BitMEXState {
    
}
struct BitMEXOrderBookState {
    private var hasPartialActionReceived = false
    private var sells = []()
    private var buys = []()
    /// Marks initial state.
    mutating func reset() {
        self = BitMEXState()
    }
    mutating func push(_ x:BitMEXChannel.Report) {
        switch x {
        case let .table(x):
            switch x.metadata.action {
            case .partial:
                hasPartialActionReceived = true
            case .insert:
                guard hasPartialActionReceived else { return }
                switch x.rows {
                case .orderBookL2(<#T##[BitMEXChannel.OrderBookL2]#>)
                }
                for row in x.rows {
                    
                }
            case .update:
                guard hasPartialActionReceived else { return }
            case .delete:
                guard hasPartialActionReceived else { return }
            }
        }
    }
}
