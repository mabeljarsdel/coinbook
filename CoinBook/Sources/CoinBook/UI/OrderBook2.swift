import Foundation
import UIKit

extension Shell {
    @available(*, deprecated)
    static func orderBook2() -> UIView & OrderBook2IO {
        return OrderBook2Impl()
    }
}
@available(*, deprecated)
protocol OrderBook2IO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
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
    func buyRowFillRatio(at row:Int) -> CGFloat? {
        let largest = largestTotalQuantity()
        let current = buy.items.elementIfExists(at: row)?.accumulatedTotalQuantity ?? 0
        return CGFloat(current) / CGFloat(largest)
    }
    func sellRowFillRatio(at row:Int) -> CGFloat? {
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







@available(*, deprecated)
private final class OrderBook2Impl: UIView, OrderBook2IO, UICollectionViewDataSource {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    private let throttle = Throttle<State>(interval: 0.1)
    private var broadcast = noop as (Action) -> Void
    
    private var isInstalled = false
    private var rendition = OrderBookRendition()
    func process(_ x:Rendition) {
        assertGCDQ(.main)
        guard let x = x.state else { return }
        if !isInstalled {
            isInstalled = true
            addSubview(collectionView)
            NSLayoutConstraint.activate([
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.register(OrderBookItemCell.self, forCellWithReuseIdentifier: OrderBookItemCell.reuseID)
            collectionView.backgroundColor = .systemBackground
            collectionView.dataSource = self
            throttle.dispatch(on: .main) { [weak self] x in self?.render(x) }
        }
        throttle.queue(x)
    }
    private func render(_ x:State) {
        assertGCDQ(.main)
        rendition = x.rendition()

        let n = rendition.maxRowCount()
        let currentRowCount = collectionView.numberOfItems(inSection: 0)
        if currentRowCount < n {
            collectionView.insertItems(at: (currentRowCount..<n).map { i in IndexPath(item: i, section: 0) })
        }
        if currentRowCount > n {
            collectionView.deleteItems(at: (n..<currentRowCount).map { i in IndexPath(item: i, section: 0) })
        }
        for i in 0..<n {
            if let cell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? OrderBookItemCell {
                cell.render(rendition, row: i)
            }
        }
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rendition.maxRowCount()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderBookItemCell.reuseID, for: indexPath)
        if let cell = cell as? OrderBookItemCell {
            cell.render(rendition, row: indexPath.row)
        }
        return cell
    }
}

private final class OrderBookItemCell: UICollectionViewCell {
    static var reuseID: String { NSStringFromClass(self) }
    private let buyTotalFillBar = UIView()
    private let buyQuantityLabel = UILabel()
    private let buyPriceLabel = UILabel()
    private let sellTotalFillBar = UIView()
    private let sellQuantityLabel = UILabel()
    private let sellPriceLabel = UILabel()
    private var isInstalled = false
    private var lastBuy = OrderItemRendition?.none
    private var lastSell = OrderItemRendition?.none
    private func installIfNeeded() {
        if !isInstalled {
            isInstalled = true
            contentView.addSubview(buyTotalFillBar)
            contentView.addSubview(buyQuantityLabel)
            contentView.addSubview(buyPriceLabel)
            contentView.addSubview(sellTotalFillBar)
            contentView.addSubview(sellPriceLabel)
            contentView.addSubview(sellQuantityLabel)
            buyTotalFillBar.backgroundColor = .systemGreen.withAlphaComponent(0.25)
            buyPriceLabel.textColor = .systemGreen
            buyPriceLabel.textAlignment = .right
            buyPriceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            buyQuantityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            sellTotalFillBar.backgroundColor = .systemRed.withAlphaComponent(0.25)
            sellQuantityLabel.textAlignment = .right
            sellPriceLabel.textColor = .systemRed
            sellPriceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
            sellQuantityLabel.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = bounds.width
        let (a,b) = bounds.divided(atDistance: w/2, from: .minXEdge)
        let (a1,a2) = a.divided(atDistance: w/4, from: .minXEdge)
        let (b1,b2) = b.divided(atDistance: w/4, from: .minXEdge)
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        buyQuantityLabel.frame = a1.inset(by: padding)
        buyPriceLabel.frame = a2.inset(by: padding)
        sellPriceLabel.frame = b1.inset(by: padding)
        sellQuantityLabel.frame = b2.inset(by: padding)
    }
    func render(_ x:OrderBookRendition, row i:Int) {
        renderBuy(x.buy.items.elementIfExists(at: i), barFillRatio: x.buyRowFillRatio(at: i))
        renderSell(x.sell.items.elementIfExists(at: i), barFillRatio: x.sellRowFillRatio(at: i))
    }
    func renderBuy(_ x:OrderItemRendition?, barFillRatio:CGFloat?) {
        guard lastBuy != x else { return }
        lastBuy = x
        installIfNeeded()
        let w = contentView.bounds.width
        buyTotalFillBar.frame = contentView.bounds
            .divided(atDistance: w/2, from: .minXEdge).slice
            .divided(atDistance: w/4, from: .maxXEdge).slice
            .divided(atDistance: w/4 * (barFillRatio ?? 0), from: .maxXEdge).slice
        buyQuantityLabel.setTextIfDifferent(x?.order.quantity.humanReadableQuantityText() ?? "????")
        buyPriceLabel.setTextIfDifferent(x?.order.price.humanReadablePriceText() ?? "????")
    }
    func renderSell(_ x:OrderItemRendition?, barFillRatio:CGFloat?) {
        guard lastSell != x else { return }
        lastSell = x
        installIfNeeded()
        let w = contentView.bounds.width
        sellTotalFillBar.frame = contentView.bounds
            .divided(atDistance: w/2, from: .maxXEdge).slice
            .divided(atDistance: w/4, from: .minXEdge).slice
            .divided(atDistance: w/4 * (barFillRatio ?? 0), from: .minXEdge).slice
        sellQuantityLabel.setTextIfDifferent(x?.order.quantity.humanReadableQuantityText() ?? "????")
        sellPriceLabel.setTextIfDifferent(x?.order.price.humanReadablePriceText() ?? "????")
    }
}


private func makeLayout() -> UICollectionViewLayout {
    let cellSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(44))
    let layout = UICollectionViewCompositionalLayout(
        section: NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.vertical(
                layoutSize: cellSize,
                subitems: [
                    NSCollectionLayoutItem(layoutSize: cellSize),
                ])))
    return layout
}
