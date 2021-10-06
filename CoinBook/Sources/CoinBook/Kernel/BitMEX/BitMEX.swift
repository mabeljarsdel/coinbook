import Foundation

final class BitMEX {
    enum Command {
        case bootstrap
    }
    enum Report {
        case state(BitMEX.State)
        case error(Error)
    }
    
    private let processq = DispatchQueue.main
    private let stateThrottle = Throttle<BitMEX.State>(interval: 0.1)
    private var broadcast = noop as (Report) -> Void
    private var chan = BitMEXChannel?.none
    private var state = BitMEX.State()
    
    init() {
        stateThrottle.dispatch(on: processq) { [weak self] state in
            self?.broadcast(.state(state))
        }
    }
    func queue(_ cmd:Command) {
        processq.async { [weak self] in self?.processCommand(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        processq.async { [weak self] in self?.broadcast = fx }
    }

    private func processCommand(_ cmd:Command) {
        assertGCDQ(processq)
        switch cmd {
        case .bootstrap:
            do {
                let newchan = try BitMEXChannel()
                newchan.dispatch { [weak self] report in self?.processq.async { self?.processBitMEXReport(report) } }
                chan = newchan
                newchan.queue(.subscribe(topics: [.orderBookL2_XBTUSD, .trade_XBT_USD]))
            }
            catch let err {
                broadcast(.error(err))
            }
        }
    }
    private func processBitMEXReport(_ report:BitMEXChannel.Report) {
        assertGCDQ(processq)
        switch report {
        case let .table(.orderBookL2(metadata, rows)):
            do {
                try state.orderBook.applyOrderTable(metadata, rows)
                stateThrottle.queue(state)
            }
            catch let err {
                broadcast(.error(err))
            }
        case let .table(.trade(metadata, rows)):
            state.recentTradeList.applyTradeTable(metadata, rows)
            stateThrottle.queue(state)
        default:
            verboseDump(report)
        }
    }
}
