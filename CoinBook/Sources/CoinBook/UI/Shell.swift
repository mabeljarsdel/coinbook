import Foundation
import UIKit

@MainActor
final class Shell {
    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let home = Shell.home2()
    private let broadcast = Chan<Action>()
    private var renderCount = 0
    
    init() {
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        window.rootViewController = home
        
        #if DEBUG
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            verboseLog("fps: \(self?.renderCount ?? -1)")
            self?.renderCount = 0
        }
        #endif
    }
    
    func render(_ x:Rendition) {
        home.process(x)
    }
    func warn(_ err:Error) {
        home.process(.warning(err))
    }
    func run() -> AsyncStream<Report> {
        AsyncStream(Report.self) { cont in
            Task { [home] in
                for await x in home.run() {
                    cont.yield(.action(x))
                }
            }
        }
    }
    enum Report {
        case action(Action)
    }
}
