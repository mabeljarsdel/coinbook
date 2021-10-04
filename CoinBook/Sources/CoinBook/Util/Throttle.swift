import Foundation
import QuartzCore

/// 10 f/s throttle.
extension Throttle {
    func queue(_ x:T) {
        processq.async { [weak self] in
            self?.enqueue(x)
            
        }
    }
    func dispatch(on gcdq:DispatchQueue, _ fx:@escaping(T)->Void) {
        processq.async { [weak self] in
            self?.broadcast = { x in
                gcdq.async {
                    fx(x)
                }
            }
        }
    }
}

final class Throttle<T> {
    private let processq = DispatchQueue(label: "Throttle")
    private let interval: TimeInterval
    private var timer = DispatchSourceTimer?.none
    private var broadcast = noop as (T)->Void
    private var msgq = T?.none
    private var lastcast = Date.distantPast
    
    init(interval x: TimeInterval) {
        interval = x
    }
    private func startTimer() {
        assertGCDQ(processq)
        guard timer == nil else { return }
        let tx = DispatchSource.makeTimerSource(flags: [], queue: processq)
        timer = tx
        let span = DispatchTimeInterval.milliseconds(Int(interval * 1000))
        tx.schedule(deadline: .now() + span, repeating: span)
        tx.setEventHandler { [weak self] in self?.onTime() }
        tx.activate()
    }
    private func stopTimer() {
        assertGCDQ(processq)
        guard let tx = timer else { return }
        tx.setEventHandler(handler: nil)
        timer = nil
    }
    
    private func enqueue(_ m:T) {
        assertGCDQ(processq)
        msgq = m
        startTimer()
    }
    private func onTime() {
        assertGCDQ(processq)
        stopTimer()
        if let m = msgq {
            msgq = nil
            lastcast = Date()
            broadcast(m)
        }
    }
}
