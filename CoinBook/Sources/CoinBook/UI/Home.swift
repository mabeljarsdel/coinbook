import Foundation
import UIKit

extension Shell {
    static func home() -> UIViewController & HomeShellIO {
        HomeShellImpl()
    }
}
protocol HomeShellIO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}

private final class HomeShellImpl: UITabBarController, HomeShellIO {
    private let orderBook = Shell.orderBook()
    private let recentTradeList = Shell.recentTradeList()
    private var broadcast = noop as (Action) -> Void
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [orderBook, recentTradeList]
        orderBook.tabBarItem = UITabBarItem(title: "Order Book", image: nil, tag: 0)
        recentTradeList.tabBarItem = UITabBarItem(title: "Recent Trades", image: nil, tag: 0)
    }
    func process(_ x:Rendition) {
        switch x {
        case .navigate(.orderBook):
            selectedViewController = orderBook
        case .navigate(.recentTrades):
            selectedViewController = recentTradeList
        case .state:
            orderBook.process(x)
            recentTradeList.process(x)
        default:
            break
        }
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
        orderBook.dispatch { [weak self] x in self?.broadcast(x) }
        recentTradeList.dispatch { [weak self] x in self?.broadcast(x) }
    }
}

