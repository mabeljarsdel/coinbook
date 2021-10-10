import Foundation

actor BitMEXChannel {
    private let rawchan: RawChannel
    private let cmdchan = Chan<Command>()
    private let jsonenc = JSONEncoder()
    private let jsondec = JSONDecoder()
    init() throws {
        rawchan = try RawChannel(address: "wss://www.bitmex.com/realtime")
    }
    func queue(_ x:Command) async {
        await cmdchan <- x
    }
    func run() -> AsyncThrowingStream<BitMEXChannel.Report,Error> {
        AsyncThrowingStream(BitMEXChannel.Report.self) { continuation in
            Task { [rawchan,cmdchan,jsonenc] in
                for try await cmd in cmdchan {
                    switch cmd {
                    case let .subscribe(topics):
                        do {
                            let m = SubscriptionOp(op: "subscribe", args: topics.map { x in x.rawValue })
                            let d = try jsonenc.encode(m)
                            let s = String(data: d, encoding: .utf8) ?? ""
                            await rawchan.queue(.sendText(s))
                        }
                        catch let err {
                            continuation.finish(throwing: err)
                        }
                    case let .unsubscribe(topics):
                        do {
                            let m = SubscriptionOp(op: "unsubscribe", args: topics.map { x in x.rawValue })
                            let d = try jsonenc.encode(m)
                            let s = String(data: d, encoding: .utf8) ?? ""
                            await rawchan.queue(.sendText(s))
                        }
                        catch let err {
                            continuation.finish(throwing: err)
                        }
                    }
                }
            }
            Task { [rawchan,jsondec] in
                for try await report in await rawchan.run() {
                    switch report {
                    case .receiveData:
                        break
                    case let .receiveText(s):
                        do {
                            perfLog("recv from raw-chan, start JSON decoding. (\(s.utf8.count) bytes)")
                            let d = s.data(using: .utf8) ?? Data()
                            let start = Date()
                            let m = try jsondec.decode(Report.self, from: d)
                            let end = Date()
                            perfLog("recv from raw-chan, end JSON decoding.  (\(s.utf8.count) bytes, \(end.timeIntervalSince(start)) sec.)")
                            continuation.yield(m)
                        }
                        catch let err {
                            continuation.finish(throwing: err)
                        }
                    }
                }
            }
        }
    }
}

private struct SubscriptionOp: Codable {
    var op: String
    var args: [String]
}
