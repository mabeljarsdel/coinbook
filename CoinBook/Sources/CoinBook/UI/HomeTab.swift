import Foundation
import UIKit

final class HomeTab: UIView {
    private let stack = UIStackView()
    private let orderBookButton = TabButton()
    private let recentTradeListButton = TabButton()
    private var isInstalled = false
    private var broadcast = noop as (Action) -> Void
    func dispatch(_ fx:@escaping(Action) -> Void) {
        broadcast = fx
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !isInstalled {
            isInstalled = true
            addSubview(stack)
            stack.autofillSuperview()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.addArrangedSubview(orderBookButton)
            stack.addArrangedSubview(recentTradeListButton)
            orderBookButton.setLabel("Order Book")
            orderBookButton.dispatch { [weak self] _ in self?.onOrderButtonTap() }
            recentTradeListButton.setLabel("Recent Trades")
            recentTradeListButton.dispatch { [weak self] _ in self?.onRecentTradeListButtonTap() }
            onOrderButtonTap()
        }
    }
    private func onOrderButtonTap() {
        orderBookButton.setSelected(true)
        recentTradeListButton.setSelected(false)
        broadcast(.navigate(.orderBook))
    }
    private func onRecentTradeListButtonTap() {
        orderBookButton.setSelected(false)
        recentTradeListButton.setSelected(true)
        broadcast(.navigate(.recentTrades))
    }
}

private final class TabButton: UIView {
    private let stack = UIStackView()
    private let button = UIButton()
    private let line = Shell.AutoLayout.horizontalLine(height: 4, color: Shell.Constant.lineColor)
    private var isInstalled = false
    private var broadcast = noop as (()) -> Void
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !isInstalled {
            isInstalled = true
            addSubview(stack)
            stack.autofillSuperview()
            stack.axis = .vertical
            stack.addArrangedSubview(button)
            stack.addArrangedSubview(line)
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 44).priority999(),
            ])
            button.setTitleColor(.systemGray3, for: .normal)
            button.setTitleColor(.systemGray, for: .selected)
            button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        }
    }
    func setLabel(_ x:String) {
        button.setTitle(x, for: .normal)
    }
    func setSelected(_ x:Bool) {
        button.isSelected = x
        line.backgroundColor = x ? UIColor.systemTeal : Shell.Constant.lineColor
    }
    func dispatch(_ fx:@escaping (()) -> Void) {
        broadcast = fx
    }
    @IBAction
    func onButtonTap(_:UIButton?) {
        broadcast(())
    }
}
