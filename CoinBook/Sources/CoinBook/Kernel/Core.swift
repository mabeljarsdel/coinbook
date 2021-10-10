import Foundation
import JJLISO8601DateFormatter

/// The core of app.
/// - Processes incoming actions, perform I/O, and update state.
actor Core {
    init() async {
    }
    func run(actions recv:Chan<Action>) -> Chan<Report> {
        let send = Chan<Report>()
        let bitmex = BitMEX()
        Task {
            await bitmex.queue(.reboot)
        }
        Task {
            for try await x in recv {
                switch x {
                case let .navigate(x):
                    await send <- .rendition(.navigate(x))
                }
            }
        }
        Task(priority: .high) { [bitmex] in
            do {
                for try await x in await bitmex.run() {
                    perfLog("recv from bitmex")
                    switch x {
                    case let .state(x): await send <- .rendition(.state(try x.scanCoreState()))
                    case let .error(x): await send <- .rendition(.warning(x))
                    }
                }
            }
            catch let err {
                await send <- .rendition(.warning(err))
            }
        }
        return send
    }
    enum Report {
        case rendition(Rendition)
    }
}
