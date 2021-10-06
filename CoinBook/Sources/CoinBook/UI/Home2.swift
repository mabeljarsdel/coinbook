import Foundation
import UIKit

extension Shell {
    static func home2() -> UIViewController & Home2IO {
        Home2Impl()
    }
}
protocol Home2IO {
    typealias Command = Rendition
    typealias Report = Action
    func process(_ x:Command)
    func dispatch(_ fx:@escaping(Report) -> Void)
}

private final class Home2Impl: UIViewController, Home2IO {
    private let tabbar = HomeTab()
    private let orderBook = Shell.orderBook3()
    private let recentTradeList = Shell.recentTradeList2()
    private var broadcast = noop as (Action) -> Void
    private var state = State()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tabbar)
        view.addSubview(orderBook)
        view.addSubview(recentTradeList)
        tabbar.translatesAutoresizingMaskIntoConstraints = false
        orderBook.translatesAutoresizingMaskIntoConstraints = false
        recentTradeList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabbar.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).priority999(),
            tabbar.bottomAnchor.constraint(equalTo: orderBook.topAnchor),
            tabbar.bottomAnchor.constraint(equalTo: recentTradeList.topAnchor),
            orderBook.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orderBook.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orderBook.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            recentTradeList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentTradeList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recentTradeList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tabbar.dispatch { [weak self] x in self?.broadcast(x) }
        orderBook.dispatch { [weak self] x in self?.broadcast(x) }
        recentTradeList.dispatch { [weak self] x in self?.broadcast(x) }
    }
    func process(_ x:Rendition) {
        switch x {
        case .navigate(.orderBook):
            orderBook.isHidden = false
            recentTradeList.isHidden = true
            view.bringSubviewToFront(orderBook)
            orderBook.process(state)
        case .navigate(.recentTrades):
            orderBook.isHidden = true
            recentTradeList.isHidden = false
            view.bringSubviewToFront(recentTradeList)
            recentTradeList.process(.setOrigin(Date()))
            recentTradeList.process(.renderState(state))
        case let .state(x):
            state = x
            if !orderBook.isHidden { orderBook.process(state) }
            if !recentTradeList.isHidden { recentTradeList.process(.renderState(state)) }
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

