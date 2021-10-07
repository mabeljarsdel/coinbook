import UIKit
import CoinBook

@main
final class Bridge: UIResponder, UIApplicationDelegate {
    private var root = Root?.none
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Task {
            root = await Root()
        }
        return true
    }
    func applicationWillTerminate(_ application: UIApplication) {
        root = nil
    }
}
