import Foundation

extension NonActorThrottle {
    func queue(_ x:T) {
        processq.async { [weak self] in self?.process(x) }
    }
    func dispatch(_ fx:@escaping(T)->Void) {
        processq.async { [weak self] in self?.broadcast = fx }
    }
}

final class NonActorThrottle<T> {
    private let processq = DispatchQueue(label: "Throttle")
    private let interval: TimeInterval
    private var broadcast = noop as (T)->Void
    private var msgq = T?.none
    private var timer = Timer?.none
    init(interval x:TimeInterval) {
        interval = x
    }
    private func process(_ m:T) {
        assertGCDQ(processq)
        msgq = m
        if timer == nil {
            onTime()
            timer = Timer.scheduledTimer(
                withTimeInterval: interval,
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
