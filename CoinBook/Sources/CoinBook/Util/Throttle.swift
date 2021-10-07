import Foundation

struct Throttle<T> {
    private let nathro: NonActorThrottle<T>
    init(interval x:TimeInterval) {
        nathro = NonActorThrottle(interval: x)
    }
    func queue(_ x:T) async {
        nathro.queue(x)
    }
    func run() -> AsyncStream<T> {
        AsyncStream { [nathro] continuation in
            Task {
                nathro.dispatch { x in
                    continuation.yield(x)
                }
            }
        }
    }
}
