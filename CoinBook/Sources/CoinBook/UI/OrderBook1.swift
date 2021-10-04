import Foundation
import UIKit

extension Shell {
    static func orderBook1() -> UIViewController & OrderBook1IO {
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
        return OrderBook1Impl(collectionViewLayout: layout)
    }
}
protocol OrderBook1IO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}

private final class OrderBook1Impl: UICollectionViewController, OrderBook1IO {
    private var state = State()
    private var broadcast = noop as (Action) -> Void
    func process(_ x:Rendition) {
        guard let x = x.state else { return }
        state = x
        let n = state.maxRowCount()
        let currentRowCount = collectionView.numberOfItems(inSection: 0)
        if currentRowCount < n {
            collectionView.insertItems(at: (currentRowCount..<n).map { i in IndexPath(item: i, section: 0) })
        }
        if currentRowCount > n {
            collectionView.deleteItems(at: (n..<currentRowCount).map { i in IndexPath(item: i, section: 0) })
        }
        for i in 0..<n {
            if let cell = collectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? OrderBookItemCell {
                let rend = state.renditionForRow(i)
                cell.render(rend)
            }
        }
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(OrderBookItemCell.self, forCellWithReuseIdentifier: OrderBookItemCell.reuseID)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        state.maxRowCount()
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderBookItemCell.reuseID, for: indexPath)
        if let cell = cell as? OrderBookItemCell {
            let book = state.orderBook
            let row = indexPath.row
            let buy = row < book.buys.count ? book.buys[row] : nil
            let sell = row < book.sells.count ? book.sells[row] : nil
            cell.render((buy,sell))
        }
        return cell
    }
}

private final class OrderBookItemCell: UICollectionViewCell {
    static var reuseID: String { NSStringFromClass(self) }
    
    private let buyQuantityLabel = UILabel()
    private let buyPriceLabel = UILabel()
    private let sellQuantityLabel = UILabel()
    private let sellPriceLabel = UILabel()
    private var isInstalled = false
    func render(_ x:(buy:State.Order?, sell:State.Order?)) {
        if !isInstalled {
            isInstalled = true
            contentView.addSubview(buyQuantityLabel)
            contentView.addSubview(buyPriceLabel)
            contentView.addSubview(sellPriceLabel)
            contentView.addSubview(sellQuantityLabel)
            buyQuantityLabel.translatesAutoresizingMaskIntoConstraints = false
            buyPriceLabel.translatesAutoresizingMaskIntoConstraints = false
            sellPriceLabel.translatesAutoresizingMaskIntoConstraints = false
            sellQuantityLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buyQuantityLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
                buyPriceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
                contentView.leadingAnchor.constraint(equalTo: buyQuantityLabel.leadingAnchor),
                buyQuantityLabel.trailingAnchor.constraint(equalTo: buyPriceLabel.leadingAnchor),
                contentView.topAnchor.constraint(equalTo: buyQuantityLabel.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: buyQuantityLabel.bottomAnchor),
                contentView.topAnchor.constraint(equalTo: buyPriceLabel.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: buyPriceLabel.bottomAnchor),
                
                sellPriceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
                sellQuantityLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
                sellPriceLabel.trailingAnchor.constraint(equalTo: sellQuantityLabel.leadingAnchor),
                sellQuantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                contentView.topAnchor.constraint(equalTo: sellQuantityLabel.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: sellQuantityLabel.bottomAnchor),
                contentView.topAnchor.constraint(equalTo: sellPriceLabel.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: sellPriceLabel.bottomAnchor),
            ])
            buyPriceLabel.textAlignment = .right
            sellQuantityLabel.textAlignment = .right
        }
        
        buyQuantityLabel.text = x.buy?.quantity.description ?? "????"
        buyPriceLabel.text = x.buy?.price.description ?? "????"
        sellQuantityLabel.text = x.sell?.quantity.description ?? "????"
        sellPriceLabel.text = x.sell?.price.description ?? "????"
    }
}


private extension State {
    func maxRowCount() -> Int {
        max(orderBook.buys.count, orderBook.sells.count)
    }
    func renditionForRow(_ row:Int) -> (buy:State.Order?, sell:State.Order?) {
        let book = orderBook
        let buy = row < book.buys.count ? book.buys[row] : nil
        let sell = row < book.sells.count ? book.sells[row] : nil
        return (buy,sell)
    }
}
