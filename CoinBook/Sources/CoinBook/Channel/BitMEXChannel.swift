import Foundation
import Starscream

final class BitMEXChannel {
    private let processq = DispatchQueue(label: "BitMEXChannel")
    private let rawchan: RawChannel
    private let jsonenc = JSONEncoder()
    private let jsondec = JSONDecoder()
    private var cast = noop as (Report) -> Void
    init() throws {
        rawchan = try RawChannel(address: "wss://www.bitmex.com/realtime")
        rawchan.dispatch { [weak self] report in self?.processq.async { self?.processRawReport(report) } }
    }
    func queue(_ cmd:Command) {
        processq.async { [weak self] in self?.processCommand(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        processq.async { [weak self] in self?.cast = fx }
    }
    
    private func processCommand(_ cmd:Command) {
        assertGCDQ(processq)
        switch cmd {
        case let .subscribe(topics):
            do {
                let m = SubscriptionOp(op: "subscribe", args: topics.map { x in x.rawValue })
                let d = try jsonenc.encode(m)
                let s = String(data: d, encoding: .utf8) ?? ""
                rawchan.queue(.sendText(s))
            }
            catch let err {
                cast(.error(err))
            }
        case let .unsubscribe(topics):
            do {
                let m = SubscriptionOp(op: "unsubscribe", args: topics.map { x in x.rawValue })
                let d = try jsonenc.encode(m)
                let s = String(data: d, encoding: .utf8) ?? ""
                rawchan.queue(.sendText(s))
            }
            catch let err {
                cast(.error(err))
            }
        }
    }
    private func processRawReport(_ report:RawChannel.Report) {
        assertGCDQ(processq)
        switch report {
        case .receiveData:
            break
        case let .receiveText(s):
            do {
                let d = s.data(using: .utf8) ?? Data()
                let m = try jsondec.decode(Report.self, from: d)
                cast(m)
            }
            catch let err {
                let f = FileHandle(forWritingAtPath: "/Users/Dev/tmp/bb")!
                f.write((s + "\n").data(using: .utf8) ?? Data())
                print(err)
                cast(.error(err))
            }
        }
    }
}

private struct SubscriptionOp: Codable {
    var op: String
    var args: [String]
}
