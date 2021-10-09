import Foundation
import UIKit

@MainActor
final class Shell {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let home = Shell.home2()
    func run(with renditions:Chan<Rendition>) -> AsyncStream<Action> {
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        window.rootViewController = home
        return AsyncStream(Action.self) { cont in
            Task {
                for await x in renditions {
                    home.process(x)
                }
            }
            Task { 
                for await x in home.run() {
                    cont.yield(x)
                }
            }
        }
    }
}
