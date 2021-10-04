import Foundation

/// 10 f/s throttle.
extension Throttle {
    func queue(_ x:T) {
        processq.async { [weak self] in self?.process(x) }
    }
    func dispatch(_ fx:@escaping(T)->Void) {
        processq.async { [weak self] in self?.broadcast = fx }
    }
}

final class Throttle<T> {
    private let processq = DispatchQueue(label: "Throttle")
    private var broadcast = noop as (T)->Void
    private var msgq = T?.none
    private var lastcast = Date.distantPast
    private func process(_ m:T) {
        assertGCDQ(processq)
        msgq = m
        if Date().timeIntervalSince(lastcast) > 0.1 {
            onTime()
        }
        else {
            processq.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in self?.onTime() }
        }
    }
    private func onTime() {
        assertGCDQ(processq)
        if let m = msgq {
            msgq = nil
            lastcast = Date()
            broadcast(m)
        }
    }
}
