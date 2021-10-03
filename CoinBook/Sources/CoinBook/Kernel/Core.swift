import Foundation
import JJLISO8601DateFormatter

/// The core of app.
/// - Processes incoming actions, perform I/O, and update state.
final class Core {
    typealias Command = Action
    typealias Report = Rendition
    
    private let processq = DispatchQueue.main
    private var broadcast = noop as (Report) -> Void
    private var chan = BitMEXChannel?.none
    private var state = State()
    
    init() {
        processq.async { [weak self] in self?.bootstrap() }
    }
    func queue(_ cmd:Command) {
        processq.async { [weak self] in self?.processAction(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        processq.async { [weak self] in self?.broadcast = fx }
    }
    
    private func bootstrap() {
        assertGCDQ(processq)
        do {
            let newchan = try BitMEXChannel()
            newchan.dispatch { [weak self] report in self?.processq.async { self?.processBitMEXReport(report) } }
            chan = newchan
            newchan.queue(.subscribe(topics: [.orderBookL2_XBTUSD, .trade_XBT_USD]))
        }
        catch let err {
            log(err)
        }
    }
    private func processAction(_ cmd:Command) {
        assertGCDQ(processq)
    }
    private func processBitMEXReport(_ report:BitMEXChannel.Report) {
        assertGCDQ(processq)
        switch report {
        case .info, .subscribe, .error:
            verboseDump(report)
        case let .table(x):
            switch x.rows {
            case let .orderBookL2(rows):
                for row in rows {
                    // TODO: Implement price/size-less case.
//                    assert(row.price != nil)
//                    assert(row.size != nil)
//                    guard let price = row.price else { continue }
//                    guard let size = row.size else { continue }
                    let price = row.price ?? -1
                    let size = row.size ?? -1
                    let order = State.Order(
                        price: price,
                        quantity: size)
                    state.push(order)
                }
            case let .trade(rows):
                let dfmt = JJLISO8601DateFormatter()
                for row in rows {
                    // TODO: Implement price/size-less case.
//                    assert(row.price != nil)
//                    assert(row.size != nil)
                    // TODO: Implement date-decoding error handling properly.
//                    assert(dfmt.date(from: row.timestamp) != nil)
//                    guard let price = row.price else { continue }
//                    guard let size = row.size else { continue }
//                    guard let time = dfmt.date(from: row.timestamp) else { continue }
                    let price = row.price ?? -1
                    let size = row.size ?? -1
                    let time = dfmt.date(from: row.timestamp) ?? .distantPast
                    let trade = State.Trade(
                        price: price,
                        quantity: size,
                        time: time)
                    state.push(trade)
                }
            case .unknown:
                verboseDump(report)
            }
        }
        broadcast(state.render())
    }
}
