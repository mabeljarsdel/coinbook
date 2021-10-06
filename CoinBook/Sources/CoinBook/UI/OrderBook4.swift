import Foundation
import UIKit

extension Shell {
    static func orderBook4() -> UIView & OrderBook4IO {
        return OrderBook3Impl()
    }
}
protocol OrderBook4IO {
    typealias Command = State
    typealias Report = Action
    func process(_ x:Command)
    func dispatch(_ fx:@escaping(Report) -> Void)
}





private struct OrderBookRendition {
    /// Descending price ordered buy orders.
    var buy = OrderBookSideRendition()
    /// Ascending price ordered buy orders.
    var sell = OrderBookSideRendition()
    func maxRowCount() -> Int {
        max(buy.items.count, sell.items.count)
    }
    func largestTotalQuantity() -> Int64 {
        max(buy.items.last?.accumulatedTotalQuantity ?? 0, sell.items.last?.accumulatedTotalQuantity ?? 0)
    }
    func buyRowFillRatio(at row:Int?) -> CGFloat? {
        guard let row = row else { return nil }
        let largest = largestTotalQuantity()
        let current = buy.items.elementIfExists(at: row)?.accumulatedTotalQuantity ?? 0
        return CGFloat(current) / CGFloat(largest)
    }
    func sellRowFillRatio(at row:Int?) -> CGFloat? {
        guard let row = row else { return nil }
        let largest = largestTotalQuantity()
        let current = sell.items.elementIfExists(at: row)?.accumulatedTotalQuantity ?? 0
        return CGFloat(current) / CGFloat(largest)
    }
}
private struct OrderBookSideRendition {
    var items = [OrderItemRendition]()
}
private struct OrderItemRendition: Equatable {
    var order: State.Order
    var accumulatedTotalQuantity: Int64
}
private extension State {
    func rendition() -> OrderBookRendition {
        OrderBookRendition(
            buy: buySideRendition(),
            sell: sellSideRendition())
    }
    func buySideRendition() -> OrderBookSideRendition {
        var rend = OrderBookSideRendition()
        rend.items = orderBook.buys.reversed().map({ x in OrderItemRendition(order: x, accumulatedTotalQuantity: 0) })
        var total = 0 as Int64
        for i in rend.items.indices {
            total += rend.items[i].order.quantity
            rend.items[i].accumulatedTotalQuantity = total
        }
        return rend
    }
    func sellSideRendition() -> OrderBookSideRendition {
        var rend = OrderBookSideRendition()
        rend.items = orderBook.sells.map({ x in OrderItemRendition(order: x, accumulatedTotalQuantity: 0) })
        var total = 0 as Int64
        for i in rend.items.indices {
            total += rend.items[i].order.quantity
            rend.items[i].accumulatedTotalQuantity = total
        }
        return rend
    }
}














private let rowHeight = 44 as CGFloat

private final class OrderBook3Impl: UIView, OrderBook4IO {
    private let stack = UIStackView()
    private let head = Shell.orderBookHead()
    private let line = Shell.AutoLayout.horizontalLine(height: 1)
    private let scroll = UIScrollView()
    private let table = OrderBookTableView()
    private let vsync = VSyncThrottle<Command>()
    private var broadcast = noop as (Action) -> Void
    private var isInstalled = false
    private var rendition = OrderBookRendition()
    override func layoutSubviews() {
        super.layoutSubviews()
        let n = rendition.maxRowCount()
        let b = bounds
        let f = CGRect(
            x: b.minX,
            y: b.minY,
            width: b.width,
            height: CGFloat(n) * rowHeight)
        table.frame = f
    }
    func process(_ x:State) {
        if !isInstalled {
            isInstalled = true
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.fillSuperview()
            stack.axis = .vertical
            stack.addArrangedSubview(head)
            stack.addArrangedSubview(line)
            stack.addArrangedSubview(scroll)
            scroll.isScrollEnabled = true
            scroll.alwaysBounceVertical = true
            scroll.addSubview(table)
            vsync.dispatch(on: .main, { [weak self] x in self?.render(x) })
        }
        vsync.queue(x)
    }
    private func render(_ x:State) {
        rendition = x.rendition()
        table.render(rendition)
        scroll.contentSize.height = CGFloat(rendition.maxRowCount()) * CGFloat(rowHeight)
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
    }
}

private final class OrderBookTableView: UIView {
    private var rendition = OrderBookRendition()
    private var rowViews = [OrderBookRowView]()
    private var isInstalled = false
    func render(_ x:OrderBookRendition) {
        if !isInstalled {
            isInstalled = true
            let n = 20
            for _ in 0..<n {
                let rowView = OrderBookRowView()
                rowViews.append(rowView)
            }
            setNeedsLayout()
        }
        
        assert(x.buy.items.map(\.accumulatedTotalQuantity) == x.buy.items.map(\.accumulatedTotalQuantity).sorted())
        assert(x.sell.items.map(\.accumulatedTotalQuantity) == x.sell.items.map(\.accumulatedTotalQuantity).sorted())
        rendition = x
        
        /// Create/delete row-views exact count of book items.
        let oldN = rowViews.count
        let newN = rendition.maxRowCount()
        if oldN < newN {
            for _ in oldN..<newN {
                let rowView = OrderBookRowView()
                rowViews.append(rowView)
                addSubview(rowView)
            }
        }
        if newN < oldN {
            for i in newN..<oldN {
                let rowView = rowViews[i]
                rowView.removeFromSuperview()
            }
            rowViews.removeSubrange(newN..<oldN)
        }
        
        /// Render all cells.
        for i in 0..<rowViews.count {
            rowViews[i].render(rendition, row: i)
        }
        
        if oldN != newN {
            setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let b = bounds
        for (i,rowView) in rowViews.enumerated() {
            let f = CGRect(
                x: b.minX,
                y: rowHeight * CGFloat(i),
                width: b.width,
                height: rowHeight)
            rowView.setFrameIfDifferent(f)
        }
    }
}

private final class OrderBookRowView: UIView {
    private let buyQuantity = LabelAndFillLayer()
    private let buyPrice = LabelAndFillLayer()
    private let sellPrice = LabelAndFillLayer()
    private let sellQuantity = LabelAndFillLayer()
    private var isInstalled = false
    private var rendition = OrderBookRendition()
    private var rowOffset = Int?.none
    private func installIfNeeded() {
        if !isInstalled {
            isInstalled = true
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.addSublayer(buyQuantity)
            layer.addSublayer(buyPrice)
            layer.addSublayer(sellPrice)
            layer.addSublayer(sellQuantity)
            buyQuantity.setStatics(
                labelTextColor: UIColor.label.cgColor,
                fillColor: UIColor.clear.cgColor)
            buyPrice.setStatics(
                labelTextColor: UIColor.label.cgColor,
                fillColor: UIColor.systemGreen.withAlphaComponent(0.25).cgColor)
            sellPrice.setStatics(
                labelTextColor: UIColor.label.cgColor,
                fillColor: UIColor.systemRed.withAlphaComponent(0.25).cgColor)
            sellQuantity.setStatics(
                labelTextColor: UIColor.label.cgColor,
                fillColor: UIColor.clear.cgColor)
            CATransaction.commit()
        }
    }
    func render(_ x:OrderBookRendition, row i:Int?) {
        installIfNeeded()
        rendition = x
        rowOffset = i
        let buy = rendition.buy.items.elementIfExists(at: rowOffset)
        let sell = rendition.sell.items.elementIfExists(at: rowOffset)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        buyQuantity.setDynamics(
            labelText: buy?.order.quantity.humanReadableQuantityText() ?? "????",
            fillRate: 0)
        buyPrice.setDynamics(
            labelText: buy?.order.price.humanReadablePriceText() ?? "????",
            fillRate: 1)
        sellPrice.setDynamics(
            labelText: sell?.order.price.humanReadablePriceText() ?? "????",
            fillRate: 1)
        sellQuantity.setDynamics(
            labelText: sell?.order.quantity.humanReadableQuantityText() ?? "????",
            fillRate: 0)
        CATransaction.commit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let (a,b) = bounds.divided(atDistance: w/2, from: .minXEdge)
        let (a1,a2) = a.divided(atDistance: w/4, from: .minXEdge)
        let (b1,b2) = b.divided(atDistance: w/4, from: .minXEdge)
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        buyQuantity.setFrameIfDifferent(a1.inset(by: padding))
        buyPrice.setFrameIfDifferent(a2.inset(by: padding))
        sellPrice.setFrameIfDifferent(b1.inset(by: padding))
        sellQuantity.setFrameIfDifferent(b2.inset(by: padding))
    }
}


private final class LabelAndFillLayer: CALayer {
    private let fill = CALayer()
    private let label = CATextLayer()
    private var latestLabelText = ""
    override init() {
        super.init()
        addSublayer(fill)
        addSublayer(label)
        label.contentsScale = UIScreen.main.scale
        label.contentsGravity = .center
        label.alignmentMode = .center
//        label.shouldRasterize = true
//        label.rasterizationScale = UIScreen.main.scale
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("unsupported.")
    }
    override func layoutSublayers() {
        super.layoutSublayers()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fill.frame = bounds
        label.frame = bounds
        CATransaction.commit()
    }
    func setStatics(labelTextColor:CGColor, fillColor:CGColor) {
        fill.backgroundColor = fillColor
        label.foregroundColor = labelTextColor
        label.font = defaultFont
        label.fontSize = UIFont.smallSystemFontSize
    }
    func setDynamics(labelText:String, fillRate:CGFloat) {
        if latestLabelText != labelText {
            label.string = labelText
        }
    }
}

private let defaultFont = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
