import Foundation
import UIKit

extension Shell {
    enum AutoLayout {
        static func empty(width: CGFloat) -> UIView {
            let x = UIView()
            x.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                x.widthAnchor.constraint(equalToConstant: width).priority999(),
            ])
            return x
        }
        static func label(text:String, alignment:NSTextAlignment) -> UILabel {
            let x = UILabel()
            x.text = text
            x.textAlignment = alignment
            x.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            return x
        }
        static func horizontalLine(height: CGFloat, color:UIColor = Constant.lineColor) -> UIView {
            let x = UIView()
            x.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                x.heightAnchor.constraint(equalToConstant: height).priority999(),
            ])
            x.backgroundColor = color
            return x
        }
    }
}





