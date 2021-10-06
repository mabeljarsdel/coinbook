import Foundation
import QuartzCore

/// Sends queued message on v-sync. Only latest message will be sent.
/// - This works only on main thread.
extension VSyncThrottle {
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

final class VSyncThrottle<T>: NSObject {
    private let processq = DispatchQueue.main
    private var displink = CADisplayLink?.none
    private var broadcast = noop as (T)->Void
    private var msgq = T?.none
    
    override init() {
        assertGCDQ(.main)
        super.init()
        displink = CADisplayLink(target: self, selector: #selector(onVSync))
        displink?.isPaused = true
        displink?.add(to: .main, forMode: .common)
    }
    deinit {
        assertGCDQ(.main)
        displink?.remove(from: .main, forMode: .common)
        displink?.invalidate()
    }
    
    private func startTimer() {
        assertGCDQ(processq)
        displink?.isPaused = false
    }
    private func stopTimer() {
        assertGCDQ(processq)
        displink?.isPaused = true
    }
    
    private func enqueue(_ m:T) {
        assertGCDQ(processq)
        msgq = m
        startTimer()
    }
    @objc
    func onVSync(_:AnyObject?) {
        assertGCDQ(processq)
        stopTimer()
        if let m = msgq {
            msgq = nil
            broadcast(m)
        }
    }
}
