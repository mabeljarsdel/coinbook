import Foundation
import UIKit

@MainActor
final class HomeTab: UIView {
    private let stack = UIStackView()
    private let orderBookButton = TabButton()
    private let recentTradeListButton = TabButton()
    private var isInstalled = false
    private var broadcast = Chan<Action>()
    
    func run() -> AsyncStream<Action> {
        AsyncStream { cont in
            Task {
                for await x in broadcast {
                    cont.yield(x)
                }
            }
            Task {
                for await _ in orderBookButton.run() {
                    orderBookButton.setSelected(true)
                    recentTradeListButton.setSelected(false)
                    await broadcast <- .navigate(.orderBook)
                }
            }
            Task {
                for await _ in recentTradeListButton.run() {
                    orderBookButton.setSelected(false)
                    recentTradeListButton.setSelected(true)
                    await broadcast <- .navigate(.recentTrades)
                }
            }
        }
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
            orderBookButton.setSelected(true)
            orderBookButton.setLabel("Order Book")
            recentTradeListButton.setSelected(false)
            recentTradeListButton.setLabel("Recent Trades")
        }
    }
}

private final class TabButton: UIView {
    private let stack = UIStackView()
    private let button = UIButton()
    private let line = Shell.AutoLayout.horizontalLine(height: 4, color: Shell.Constant.lineColor)
    private var isInstalled = false
    private var broadcast = Chan<()>()
    
    func run() -> AsyncStream<()> {
        AsyncStream { cont in
            Task {
                for await x in broadcast {
                    cont.yield(x)
                }
            }
        }
    }
    
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
    @IBAction
    func onButtonTap(_:UIButton?) {
        Task() {
            await broadcast <- ()
        }
    }
}
