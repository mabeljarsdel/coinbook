import Foundation
import UIKit

extension Shell {
    @available(*, deprecated)
    static func home1() -> UIViewController & Home1IO {
        Home1Impl()
    }
}
@available(*, deprecated)
protocol Home1IO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}

@available(*, deprecated)
private final class Home1Impl: UITabBarController, Home1IO {
    private let orderBook = Shell.orderBook1()
    private let recentTradeList = Shell.recentTradeList1()
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

