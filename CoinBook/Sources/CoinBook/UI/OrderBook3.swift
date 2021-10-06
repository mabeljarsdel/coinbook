import Foundation
import UIKit

extension Shell {
    static func orderBook3() -> UIView & OrderBook3IO {
        return OrderBook3Impl()
    }
}
protocol OrderBook3IO {
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

private final class OrderBook3Impl: UIView, OrderBook3IO, UIScrollViewDelegate {
    private let stack = UIStackView()
    private let head = Shell.orderBookHead()
    private let line = Shell.AutoLayout.horizontalLine(height: 1)
    private let scroll = UIScrollView()
    private let table = OrderBookTableView()
    private let vsync = VSyncThrottle<OrderBookRendition>()
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
            scroll.delegate = self
            vsync.dispatch(on: .main, { [weak self] x in self?.render(x) })
        }
        vsync.queue(x.rendition())
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        render(rendition)
    }
    private func render(_ x:OrderBookRendition) {
        rendition = x
        let vb = convert(bounds, to: table)
        table.render(rendition, visibleBounds: vb)
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
    func render(_ x:OrderBookRendition, visibleBounds:CGRect) {
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
            if visibleBounds.intersects(rowViews[i].frame) {
                rowViews[i].render(rendition, row: i)
            }
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
    private let buyTotalFillBar = FillView()
    private let buyQuantityLabel = UILabel()
    private let buyPriceLabel = UILabel()
    private let sellTotalFillBar = FillView()
    private let sellQuantityLabel = UILabel()
    private let sellPriceLabel = UILabel()
    private var isInstalled = false
    private var rendition = OrderBookRendition()
    private var rowOffset = Int?.none
    private func installIfNeeded() {
        if !isInstalled {
            isInstalled = true
            addSubview(buyTotalFillBar)
            addSubview(buyQuantityLabel)
            addSubview(buyPriceLabel)
            addSubview(sellTotalFillBar)
            addSubview(sellPriceLabel)
            addSubview(sellQuantityLabel)
            buyTotalFillBar.isHorizontallyReversed = true
            buyTotalFillBar.fillColor = .systemGreen.withAlphaComponent(0.25)
            buyPriceLabel.textColor = .systemGreen
            buyPriceLabel.textAlignment = .right
            buyPriceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            buyPriceLabel.adjustsFontSizeToFitWidth = true
            buyQuantityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            buyQuantityLabel.adjustsFontSizeToFitWidth = true
            sellTotalFillBar.fillColor = .systemRed.withAlphaComponent(0.25)
            sellQuantityLabel.textAlignment = .right
            sellPriceLabel.textColor = .systemRed
            sellPriceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            sellPriceLabel.adjustsFontSizeToFitWidth = true
            sellQuantityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            sellQuantityLabel.adjustsFontSizeToFitWidth = true
        }
    }
    func render(_ x:OrderBookRendition, row i:Int?) {
        installIfNeeded()
        rendition = x
        rowOffset = i
        let buy = rendition.buy.items.elementIfExists(at: rowOffset)
        let sell = rendition.sell.items.elementIfExists(at: rowOffset)
        buyQuantityLabel.setTextIfDifferent(buy?.order.quantity.humanReadableQuantityText())
        buyPriceLabel.setTextIfDifferent(buy?.order.price.humanReadablePriceText() ?? "????")
        sellQuantityLabel.setTextIfDifferent(sell?.order.quantity.humanReadableQuantityText())
        sellPriceLabel.setTextIfDifferent(sell?.order.price.humanReadablePriceText() ?? "????")
        buyTotalFillBar.fillRate = rendition.buyRowFillRatio(at: rowOffset) ?? 0
        sellTotalFillBar.fillRate = rendition.sellRowFillRatio(at: rowOffset) ?? 0
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let (a,b) = bounds.divided(atDistance: w/2, from: .minXEdge)
        let (a1,a2) = a.divided(atDistance: w/4, from: .minXEdge)
        let (b1,b2) = b.divided(atDistance: w/4, from: .minXEdge)
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        buyQuantityLabel.setFrameIfDifferent(a1.inset(by: padding))
        buyTotalFillBar.setFrameIfDifferent(a2)
        buyPriceLabel.setFrameIfDifferent(a2.inset(by: padding))
        sellTotalFillBar.setFrameIfDifferent(b1)
        sellPriceLabel.setFrameIfDifferent(b1.inset(by: padding))
        sellQuantityLabel.setFrameIfDifferent(b2.inset(by: padding))
    }
}

private final class FillView: UIView {
    private let barLayer = CALayer()
    private var isInstalled = false
    
    var isHorizontallyReversed = false
    var fillColor = UIColor.white {
        didSet {
            barLayer.backgroundColor = fillColor.cgColor
        }
    }
    var fillRate = 0 as CGFloat {
        didSet {
            if !isInstalled {
                isInstalled = true
                layer.addSublayer(barLayer)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        barLayer.frame = isHorizontallyReversed
            ? layer.bounds.divided(atDistance: layer.bounds.width * fillRate, from: .maxXEdge).slice
            : layer.bounds.divided(atDistance: layer.bounds.width * fillRate, from: .minXEdge).slice
        CATransaction.commit()
    }
}
