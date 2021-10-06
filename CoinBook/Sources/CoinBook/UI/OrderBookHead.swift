import Foundation
import UIKit

extension Shell {
    static func orderBookHead() -> UIView {
        OrderBookHeadImpl()
    }
}




private final class OrderBookHeadImpl: UIView {
    private let stackView = UIStackView()
    private var isInstalled = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !isInstalled {
            isInstalled = true
            addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.fillSuperview()
            NSLayoutConstraint.activate([
                stackView.heightAnchor.constraint(equalToConstant: 44).priority999(),
            ])
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.addArrangedSubview(empty(width: 10))
            stackView.addArrangedSubview(label(text: "Qty", alignment: .left))
            stackView.addArrangedSubview(label(text: "Price(USD)", alignment: .center))
            stackView.addArrangedSubview(label(text: "Qty", alignment: .right))
            stackView.addArrangedSubview(empty(width: 10))
            NSLayoutConstraint.activate([
                stackView.arrangedSubviews[1].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
                stackView.arrangedSubviews[3].widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            ])
        }
    }
}

private func empty(width: CGFloat) -> UIView {
    let x = UIView()
    x.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        x.widthAnchor.constraint(equalToConstant: width).priority999(),
    ])
    return x
}

private func label(text:String, alignment:NSTextAlignment) -> UILabel {
    let x = UILabel()
    x.text = text
    x.textAlignment = alignment
    x.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    return x
}
