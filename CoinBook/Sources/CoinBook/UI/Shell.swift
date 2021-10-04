import Foundation
import UIKit

/// Root of UI.
extension Shell {
    typealias Command = Rendition
    typealias Report = Action
    func queue(_ cmd:Command) {
        DispatchQueue.main.async { [weak self] in self?.process(cmd) }
    }
    func dispatch(_ fx: @escaping (Report) -> Void) {
        broadcast = fx
    }
}
final class Shell {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let home = Shell.home()
    private var broadcast = noop as (Report) -> Void
    private var renderCount = 0
    init() {
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        window.rootViewController = home
        home.dispatch { [weak self] x in self?.broadcast(x) }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            print("fps: \(self?.renderCount ?? -1)")
            self?.renderCount = 0
        }
    }
}

private extension Shell {
    func process(_ cmd:Command) {
        assertGCDQ(.main)
        home.process(cmd)
        renderCount += 1
    }
}
