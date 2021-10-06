import Foundation
import UIKit

extension String {
    func attributed() -> NSAttributedString {
        NSAttributedString(string: self)
    }
}
extension NSAttributedString {
    func foregroundColor(_ c:UIColor) -> NSAttributedString {
        let x = NSMutableAttributedString(attributedString: self)
        x.setAttributes([.foregroundColor: c], range: NSRange(location: 0, length: length))
        return x
    }
    func foregroundColor(_ c:CGColor) -> NSAttributedString {
        let x = NSMutableAttributedString(attributedString: self)
        x.setAttributes([.foregroundColor: c], range: NSRange(location: 0, length: length))
        return x
    }
    func font(_ f:UIFont) -> NSAttributedString {
        let x = NSMutableAttributedString(attributedString: self)
        x.setAttributes([.font: f as CTFont], range: NSRange(location: 0, length: length))
        return x
    }
    static func + (_ a:NSAttributedString, _ b:NSAttributedString) -> NSAttributedString {
        let x = NSMutableAttributedString()
        x.append(a)
        x.append(b)
        return x
    }
}
