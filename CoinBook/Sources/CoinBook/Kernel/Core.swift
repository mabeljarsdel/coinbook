import Foundation
import JJLISO8601DateFormatter

/// The core of app.
/// - Processes incoming actions, perform I/O, and update state.
actor Core {
    private let bitmex = BitMEX()
    private let action = Chan<Action>()
    
    init() async {
        Task { await bitmex.queue(.reboot) }
    }
    func execute(_ x:Action) async {
        await action <- x
    }
    func run() -> AsyncStream<Report> {
        AsyncStream(Report.self) { [action] continuation in
            Task {
                for try await x in action {
                    switch x {
                    case let .navigate(x):
                        continuation.yield(.rendition(.navigate(x)))
                    }
                }
            }
            Task { [bitmex] in
                do {
                    for try await x in await bitmex.run() {
                        switch x {
                        case let .state(x): continuation.yield(.rendition(.state(try x.scanCoreState())))
                        case let .error(x): continuation.yield(.rendition(.warning(x)))
                        }
                    }
                }
                catch let err {
                    continuation.yield(.rendition(.warning(err)))
                }
            }
        }
    }
    enum Report {
        case rendition(Rendition)
    }
}
