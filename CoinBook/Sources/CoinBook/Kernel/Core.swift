import Foundation
import JJLISO8601DateFormatter

/// The core of app.
/// - Processes incoming actions, perform I/O, and update state.
final class Core {
    typealias Command = Action
    typealias Report = Rendition
    
    private let processq = DispatchQueue.main
    private var broadcast = noop as (Report) -> Void
    
    private let bitmex = BitMEX()
    private var state = State()
    
    init() {
        bitmex.dispatch { [weak self] x in self?.processq.async { self?.processBitMEXReport(x) } }
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
        bitmex.queue(.bootstrap)
    }
    private func processAction(_ cmd:Command) {
        assertGCDQ(processq)
        switch cmd {
        case let .navigate(x):
            broadcast(.navigate(x))
        }
    }
    private func processBitMEXReport(_ report:BitMEX.Report) {
        assertGCDQ(processq)
        switch report {
        case let .state(x):
            do {
                state.orderBook = try x.orderBook.scanCoreState()
                broadcast(.state(state))
            }
            catch let err {
                broadcast(.warning(err))
            }
        case let .error(err):
            log(err)
            broadcast(.warning(err))
        }
    }
}
