import Foundation

final class FPS {
    private let label: String
    private let sync = DispatchQueue(label: "FPS")
    private var timer = Timer?.none
    private var count = 0
    private var fps = 0
    init(label s: String) {
        label = s
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in self?.measure() }
    }
    func increment() {
        sync.sync {
            count += 1
        }
    }
    private func measure() {
        sync.sync {
            fps = count
            count = 0
            #if DEBUG
            print("FPS(\(label)): \(fps)")
            #endif
        }
    }
}
