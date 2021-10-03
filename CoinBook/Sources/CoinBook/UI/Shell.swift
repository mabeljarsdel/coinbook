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
    init() {
        window.makeKeyAndVisible()
        window.rootViewController = home
        home.dispatch { [weak self] x in self?.broadcast(x) }
    }
}

private extension Shell {
    func process(_ cmd:Command) {
        assertGCDQ(.main)
        home.process(cmd)
    }
}
