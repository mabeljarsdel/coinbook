import Foundation
import UIKit
import JJLISO8601DateFormatter

extension URL {
    static func from(expression s:String) throws -> URL {
        guard let u = URL(string: s) else { throw Issue.badURLCode(s) }
        return u
    }
}

func noop<T>(_:T) {}

/// Asserts current executing GCDQ.
/// Panics if current GCDQ is not designated one.
/// No-op in optimized build.
func assertGCDQ(_ gcdq: @autoclosure() -> DispatchQueue) {
    #if DEBUG
    dispatchPrecondition(condition: .onQueue(gcdq()))
    #endif
}









extension Date {
    func humanReadableTimeText() -> String {
        timeForm.string(from: self)
    }
}
private let timeForm = {
    assertGCDQ(.main)
    let x = JJLISO8601DateFormatter()
    x.formatOptions = [
        .withTime,
        .withColonSeparatorInTime,
    ]
    x.timeZone = TimeZone.current
    return x
}() as JJLISO8601DateFormatter


extension Int64 {
    func humanReadableQuantityText() -> String {
        assertGCDQ(.main)
        return quantityNumForm.string(from: NSNumber(value: self)) ?? ""
    }
}
private let quantityNumForm = {
    assertGCDQ(.main)
    let x = NumberFormatter()
    x.numberStyle = .decimal
    x.maximumFractionDigits = 0
    x.minimumFractionDigits = 0
    return x
}() as NumberFormatter


extension Double {
    func humanReadablePriceText() -> String {
        assertGCDQ(.main)
        return priceNumForm.string(from: NSNumber(value: self)) ?? ""
    }
}
private let priceNumForm = {
    assertGCDQ(.main)
    let x = NumberFormatter()
    x.numberStyle = .decimal
    x.maximumFractionDigits = 1
    x.minimumFractionDigits = 1
    return x
}() as NumberFormatter

extension NSLayoutConstraint {
    func priority999() -> NSLayoutConstraint {
        priority = UILayoutPriority(999)
        return self
    }
}

extension UILabel {
    func setTextIfDifferent(_ s:String?) {
        guard s != text else { return }
        text = s
    }
    func setTextColorIfDifferent(_ s:UIColor?) {
        guard s != textColor else { return }
        textColor = s
    }
}


extension CALayer {
    func setFrameIfDifferent(_ f:CGRect) {
        guard f != frame else { return }
        frame = f
    }
}
extension UIView {
    func setFrameIfDifferent(_ f:CGRect) {
        guard f != frame else { return }
        frame = f
    }
    func autofillSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        fillSuperviewHorizontally()
        fillSuperviewVertically()
    }
    func fillSuperview() {
        fillSuperviewHorizontally()
        fillSuperviewVertically()
    }
    func fillSuperviewHorizontally() {
        assert(translatesAutoresizingMaskIntoConstraints == false)
        assert(superview != nil)
        guard let v = superview else { return }
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    func fillSuperviewVertically() {
        assert(translatesAutoresizingMaskIntoConstraints == false)
        assert(superview != nil)
        guard let v = superview else { return }
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: topAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}









extension Array {
    func elementIfExists(at i:Int?) -> Element? {
        guard let i = i else { return nil }
        guard i < count else { return nil }
        return self[i]
    }
}
