import Foundation

actor RawChannel {
    typealias Command = NonActorRawChannel.Command
    typealias Report = NonActorRawChannel.Report
    private let narc: NonActorRawChannel
    private let narcReportChan = Chan<NonActorRawChannel.Report>()
    init(address:String) throws {
        narc = try NonActorRawChannel(address: address)
        narc.dispatch { [narcReportChan] x in
            Task { await narcReportChan.queue(x) }
        }
    }
    func queue(_ cmd:Command) {
        narc.queue(cmd)
    }
    func run() -> AsyncStream<Report> {
        AsyncStream(Report.self) { [narcReportChan] continuation in
            Task { [narcReportChan] in
                for try await report in narcReportChan {
                    switch report {
                    case let .receiveText(s):
                        continuation.yield(.receiveText(s))
                    case let .receiveData(d):
                        continuation.yield(.receiveData(d))
                    }
                }
            }
        }
    }
}
