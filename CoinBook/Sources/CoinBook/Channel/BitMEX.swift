import Foundation

actor BitMEX {
    enum Command {
        case reboot
    }
    enum Report {
        case state(BitMEX.State)
        /// An error occured.
        /// - Stream connection to BitMEX has already been invalidated.
        /// - You need to send `.bootstrap` command to recover the connection.
        case error(Error)
    }
    
    private let cmdchan = Chan<Command>()
    private var implChan = BitMEXChannel?.none
    private var state = BitMEX.State()
    
    private func setChan(_ newchan:BitMEXChannel) {
        implChan = newchan
    }
    private func applyChannelReport(_ report:BitMEXChannel.Report) -> Result<Report,Error>? {
        switch report {
        case let .table(.orderBookL2(metadata, rows)):
            do {
                try state.orderBook.applyOrderTable(metadata, rows)
                return .success(.state(state))
            }
            catch let err {
                return .failure(err)
            }
        case let .table(.trade(metadata, rows)):
            state.recentTradeList.applyTradeTable(metadata, rows)
            return .success(.state(state))
        default:
            verboseDump(report)
            return nil
        }
    }
    
    func queue(_ cmd:Command) async {
        await cmdchan <- cmd
    }
    func run() -> AsyncStream<Report> {
        AsyncStream { cont in
            Task { [weak self, cmdchan] in
                for try await cmd in cmdchan {
                    switch cmd {
                    case .reboot:
                        do {
                            let newchan = try BitMEXChannel()
                            await self?.setChan(newchan)
                            await newchan.queue(.subscribe(topics: [.orderBookL2_XBTUSD, .trade_XBT_USD]))
                            Task { [weak self] in
                                for try await report in await newchan.run() {
                                    guard let ss = self else { continue }
                                    guard let r = await ss.applyChannelReport(report) else { continue }
                                    switch r {
                                    case let .success(x): cont.yield(x)
                                    case let .failure(err): cont.yield(.error(err))
                                    }
                                }
                            }
                        }
                        catch let err {
                            cont.yield(.error(err))
                        }
                    }
                }
            }
        }
    }
}

