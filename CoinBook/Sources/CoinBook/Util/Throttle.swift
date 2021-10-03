import Foundation

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
    private var timer = Timer?.none
    private func process(_ m:T) {
        assertGCDQ(processq)
        msgq = m
        if timer == nil {
            onTime()
            timer = Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: false,
                block: { [weak self] _ in self?.onTime() })
        }
    }
    private func onTime() {
        assertGCDQ(processq)
        timer?.invalidate()
        timer = nil
        if let m = msgq {
            msgq = nil
            broadcast(m)
        }
    }
}
