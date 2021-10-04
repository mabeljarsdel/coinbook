import Foundation
import UIKit

private let toolbarHeight = CGFloat(40)
private let separatorHeight = CGFloat(4)

final class HomeTabBarView: UIView {
    private let orderBookButton = UIButton()
    private let recentTradeListButton = UIButton()
    private let separatorView = UIView()
    private var isInstalled = false
    private var broadcast = noop as (Action) -> Void
    func dispatch(_ fx:@escaping(Action) -> Void) {
        broadcast = fx
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !isInstalled {
            isInstalled = true
            addSubview(orderBookButton)
            addSubview(recentTradeListButton)
            addSubview(separatorView)
            orderBookButton.translatesAutoresizingMaskIntoConstraints = false
            recentTradeListButton.translatesAutoresizingMaskIntoConstraints = false
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                orderBookButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                orderBookButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
                orderBookButton.topAnchor.constraint(equalTo: topAnchor),
                orderBookButton.heightAnchor.constraint(equalToConstant: toolbarHeight).priority999(),
                orderBookButton.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
                recentTradeListButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
                recentTradeListButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                recentTradeListButton.topAnchor.constraint(equalTo: topAnchor),
                recentTradeListButton.heightAnchor.constraint(equalToConstant: toolbarHeight).priority999(),
                recentTradeListButton.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
                
                separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: separatorHeight).priority999(),
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            orderBookButton.setTitle("Order Book", for: .normal)
            orderBookButton.setTitleColor(.systemGray, for: .normal)
            orderBookButton.addTarget(self, action: #selector(onOrderButtonTap(_:)), for: .touchUpInside)
            recentTradeListButton.setTitle("Recent Trades", for: .normal)
            recentTradeListButton.setTitleColor(.systemGray, for: .normal)
            recentTradeListButton.addTarget(self, action: #selector(onRecentTradeListButtonTap(_:)), for: .touchUpInside)
            separatorView.backgroundColor = .systemGray6
        }
    }
    @IBAction
    private func onOrderButtonTap(_:UIButton) {
        broadcast(.navigate(.orderBook))
    }
    @IBAction
    private func onRecentTradeListButtonTap(_:UIButton) {
        broadcast(.navigate(.recentTrades))
    }
    
}


