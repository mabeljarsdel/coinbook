import Foundation
import UIKit

extension Shell {
    static func recentTradeList2() -> UIView & RecentTradeList2IO {
        RecentTradeList2Impl()
    }
}
protocol RecentTradeList2IO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}




private let rowHeight = CGFloat(44)

private struct TradeListRendition {
    var state = State()
    func containerHeight() -> CGFloat {
        CGFloat(state.trades.count) * rowHeight
    }
}

private final class RecentTradeList2Impl: UIView, RecentTradeList2IO {
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let tableView = TableView()
    private var isInstalled = false
    private var rendition = TradeListRendition()
    func process(_ x: Rendition) {
        guard let state = x.state else { return }
        if !isInstalled {
            isInstalled = true
            addSubview(scrollView)
            scrollView.isScrollEnabled = true
            scrollView.alwaysBounceVertical = true
            scrollView.addSubview(containerView)
            containerView.addSubview(tableView)
        }
        rendition = TradeListRendition(state: state)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.06)
        tableView.render(rendition)
        CATransaction.commit()
        setNeedsLayout()
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollView.frame != bounds { scrollView.frame = bounds }
        let h = rendition.containerHeight()
        scrollView.contentSize.height = h
        containerView.frame.size = CGSize(width: bounds.width, height: h)
        tableView.frame = containerView.bounds
    }
}

private final class TableView: UIView {
    private var rowViews = [RowView]()
    private var rendition = TradeListRendition()
    func render(_ newRendition:TradeListRendition) {
        let old = rendition
        let new = newRendition
        let oldIDSet = Set(old.state.trades.map { x in x.id })
        let newIDSet = Set(new.state.trades.map { x in x.id })
        let removedIDSet = oldIDSet.subtracting(newIDSet)
        
        typealias ID = String
        let oldRowViews = rowViews
        let idOldRowViewMap = Dictionary(uniqueKeysWithValues: zip(old.state.trades.lazy.map({ x in x.id }), oldRowViews))
        /// Remove removed row views.
        for id in removedIDSet {
            if let rowView = idOldRowViewMap[id] {
                rowView.removeFromSuperview()
            }
        }
        /// Add new row views.
        func makeAndAddRowView(_ x:State.TradeSide?) -> RowView {
            let rowView = RowView()
            addSubview(rowView)
            rowView.backgroundColor = x?.humanReadableTextColor().withAlphaComponent(0.25)
            UIView.animate(withDuration: 0.3) {
                rowView.backgroundColor = UIColor.clear
            }
            return rowView
        }
        let newRowViews = new.state.trades.map({ x in idOldRowViewMap[x.id] ?? makeAndAddRowView(x.side) })
        rowViews = newRowViews
        
        /// Replace rendition.
        rendition = newRendition
        for i in rowViews.indices {
            let rowData = new.state.trades[i]
            let rowLayer = rowViews[i]
            rowLayer.render(rowData)
        }
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        for i in rowViews.indices {
            let rowLayer = rowViews[rowViews.count - i - 1]
            let y = CGFloat(i) * rowHeight
            let f = CGRect(x: 0, y: y, width: w, height: rowHeight)
            rowLayer.frame = f
        }
    }
}

private final class RowView: UIView {
    private let priceTextLayer = UILabel()
    private let quantityTextLayer = UILabel()
    private let timeTextLayer = UILabel()
    private var isInstalled = false
    func render(_ x:State.Trade) {
        if !isInstalled {
            isInstalled = true
            addSubview(priceTextLayer)
            addSubview(quantityTextLayer)
            addSubview(timeTextLayer)
            priceTextLayer.textAlignment = .left
            priceTextLayer.contentMode = .center
            priceTextLayer.font = .monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            quantityTextLayer.textAlignment = .right
            quantityTextLayer.contentMode = .center
            quantityTextLayer.font = .monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            timeTextLayer.textAlignment = .right
            timeTextLayer.contentMode = .center
            timeTextLayer.font = .monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
        }
        priceTextLayer.setTextIfDifferent(x.price.humanReadablePriceText())
        priceTextLayer.setTextColorIfDifferent(x.side?.humanReadableTextColor())
        quantityTextLayer.setTextIfDifferent(x.quantity.humanReadableQuantityText())
        quantityTextLayer.setTextColorIfDifferent(x.side?.humanReadableTextColor())
        timeTextLayer.setTextIfDifferent(x.time.humanReadableTimeText())
        timeTextLayer.setTextColorIfDifferent(x.side?.humanReadableTextColor())
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width * 0.4
        let a = bounds.divided(atDistance: w, from: .minXEdge).slice.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        let b = bounds.inset(by: UIEdgeInsets(top: 0, left: w, bottom: 0, right: w))
        let c = bounds.divided(atDistance: w, from: .maxXEdge).slice.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        priceTextLayer.frame = a
        quantityTextLayer.frame = b
        timeTextLayer.frame = c
    }
}


private extension State.TradeSide {
    func humanReadableTextColor() -> UIColor {
        switch self {
        case .buy: return .systemGreen
        case .sell: return .systemRed
        }
    }
}
