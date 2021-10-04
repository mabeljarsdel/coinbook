import Foundation

extension BitMEX.OrderBook {
    func scanCoreState() throws -> State.OrderBook {
        let n = 20
        var result = State.OrderBook()
        for buy in buys.suffix(n) {
            guard let record = table[buy.id] else { throw Issue.bitMEX(.missingRecordForIDOnScanningTops(buy.id)) }
            result.buys.append(State.Order(price: buy.price, quantity: record.size))
        }
        for sell in sells.prefix(n) {
            guard let record = table[sell.id] else { throw Issue.bitMEX(.missingRecordForIDOnScanningTops(sell.id)) }
            result.sells.append(State.Order(price: sell.price, quantity: record.size))
        }
        return result
    }
}
extension BitMEX {
    struct State {
        var orderBook = OrderBook()
        var recentTradeList = RecentTradeList()
    }
    struct OrderBook {
        typealias ID = Int64
        typealias Price = Double
        struct Record {
            var symbol: String
            var size: Int64
            var price: Price
        }
        
        /// Resets to initial state.
        mutating func reset() {
            self = OrderBook()
        }
        /// Performs atomic transaction of order merge.
        /// Rollback whole state on any error.
        mutating func applyOrderTable(_ metadata:BitMEXChannel.TableMetadata, _ rows:[BitMEXChannel.OrderBookL2]) throws {
            let old = self
            do {
                try applyOrderTableNaively(metadata, rows)
            }
            catch let err {
                self = old
                throw err
            }
        }
        
        private var hasPartialActionReceived = false
        private var table = BTMap<ID,Record>()
        private var buys = BTSortedSet<PriceSortedIndex>()
        private var sells = BTSortedSet<PriceSortedIndex>()
        /// This will globally unique as `id` will be counted in equality and comparison operations,
        private struct PriceSortedIndex: Equatable, Comparable {
            var price: Double
            var id: ID
            static func < (_ a:PriceSortedIndex, _ b:PriceSortedIndex) -> Bool {
                if a.price < b.price { return true }
                if a.price == b.price { return a.id < b.id }
                return false
            }
        }
        private mutating func applyOrderTableNaively(_ metadata:BitMEXChannel.TableMetadata, _ rows:[BitMEXChannel.OrderBookL2]) throws {
            if metadata.action == .partial { hasPartialActionReceived = true }
            guard hasPartialActionReceived else { return }
            switch metadata.action {
            case .partial:
                /// Rows are snapshot at some point.
                /// Replace all items.
                buys.removeAll()
                sells.removeAll()
                table.removeAll()
                fallthrough
                
            case .insert:
                for row in rows {
                    guard let size = row.size else { throw Issue.bitMEX(.missingSizeOrPriceFieldInPartialActionTable(row)) }
                    guard let price = row.price else { throw Issue.bitMEX(.missingSizeOrPriceFieldInPartialActionTable(row)) }
                    let id = row.id
                    let record = Record(symbol: row.symbol, size: size, price: price)
                    table[row.id] = record
                    switch row.side.lowercased() {
                    case "buy": buys.insert(PriceSortedIndex(price: price, id: id))
                    case "sell": sells.insert(PriceSortedIndex(price: price, id: id))
                    default: throw Issue.bitMEX(.badSideValue(row))
                    }
                }
                
            case .update:
                for row in rows {
                    let id = row.id
                    guard var record = table[id] else { throw Issue.bitMEX(.missingRecordForIDOnUpdateOrDelete(row))}
                    /// We do not know which field has been updated.
                    /// Remove and re-insert all indices for sure.
                    buys.remove(PriceSortedIndex(price: record.price, id: id))
                    sells.remove(PriceSortedIndex(price: record.price, id: id))
                    if let size = row.size { record.size = size }
                    if let price = row.price { record.price = price }
                    table[id] = record
                    table[row.id] = record
                    switch row.side.lowercased() {
                    case "buy": buys.insert(PriceSortedIndex(price: record.price, id: id))
                    case "sell": sells.insert(PriceSortedIndex(price: record.price, id: id))
                    default: throw Issue.bitMEX(.badSideValue(row))
                    }
                }
                
            case .delete:
                for row in rows {
                    guard let record = table[row.id] else { throw Issue.bitMEX(.missingRecordForIDOnUpdateOrDelete(row))}
                    buys.remove(PriceSortedIndex(price: record.price, id: row.id))
                    sells.remove(PriceSortedIndex(price: record.price, id: row.id))
                    table[row.id] = nil
                }
            }
        }
        mutating func applyTradeTable(_ metadata:BitMEXChannel.TableMetadata, rows:[BitMEXChannel.Trade]) {
            if metadata.action == .partial { hasPartialActionReceived = true }
            guard hasPartialActionReceived else { return }
        }
    }
    struct RecentTradeList {
        private var table = BTSortedSet<PerfectOrderedTrade>()
        private struct PerfectOrderedTrade: Equatable, Comparable {
            var trade: BitMEXChannel.Trade
            /// We need this as I couldn't find guaranteed uniqueness value of trade record.
            var uniqueness = Uniqueness()
            static func == (_ a:PerfectOrderedTrade, _ b:PerfectOrderedTrade) -> Bool {
                a.uniqueness == b.uniqueness
            }
            static func < (_ a:PerfectOrderedTrade, _ b:PerfectOrderedTrade) -> Bool {
                if a.trade.timestamp < b.trade.timestamp { return true }
                if a.trade.timestamp == b.trade.timestamp { return a.uniqueness < b.uniqueness }
                return false
            }
        }
        func scanRecentTrades() -> [BitMEXChannel.Trade] {
            table.map({ x in x.trade })
        }
        mutating func applyTradeTable(_ metadata:BitMEXChannel.TableMetadata, _ rows:[BitMEXChannel.Trade]) {
            let n = 30
            /// Spec designates that trade informationa are all INSERT.
            for row in rows {
                if table.count >= n { table.removeFirst(table.count - n) }
                if table.count >= n { table.removeFirst() }
                table.insert(PerfectOrderedTrade(trade: row))
            }
        }
    }
}
