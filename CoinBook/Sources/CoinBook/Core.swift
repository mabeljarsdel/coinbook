import Foundation

/// The core of app.
/// - Processes incoming actions, perform I/O, and update state.
final class Core {
    typealias Command = Action
    typealias Report = Rendition
    
    private let processq = DispatchQueue.main
    private var cast = noop as (Report) -> Void
    private var chan = BitMEXChannel?.none
    private var state = State()
    
    init() {
        processq.async { [weak self] in self?.prep() }
    }
    func queue(_ cmd:Command) {
        processq.async { [weak self] in self?.processAction(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        processq.async { [weak self] in self?.cast = fx }
    }
    
    private func prep() {
        assertGCDQ(processq)
        do {
            let newchan = try BitMEXChannel()
            newchan.dispatch { [weak self] report in self?.processq.async { self?.processBitMEXReport(report) } }
            chan = newchan
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
//        switch report {
//        case let .success(subscription, success):
//        case let .error(string):
//        }
    }
}
