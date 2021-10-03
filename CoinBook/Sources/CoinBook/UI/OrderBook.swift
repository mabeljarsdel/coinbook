import Foundation
import UIKit

extension Shell {
    static func orderBook() -> UIViewController & OrderBookShellIO {
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
        return OrderBookShellImpl(collectionViewLayout: layout)
    }
}
protocol OrderBookShellIO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}

private final class OrderBookShellImpl: UICollectionViewController, OrderBookShellIO {
    private var state = State()
    private var broadcast = noop as (Action) -> Void
    func process(_ x:Rendition) {
        guard let x = x.state else { return }
        state = x
        collectionView.reloadData()
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(OrderBookItemCell.self, forCellWithReuseIdentifier: OrderBookItemCell.reuseID)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        max(state.orderBook.buys.count, state.orderBook.sells.count)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderBookItemCell.reuseID, for: indexPath)
        if let cell = cell as? OrderBookItemCell {
            let book = state.orderBook
            let row = indexPath.row
            let buy = row < book.buys.count ? book.buys[row] : nil
            let sell = row < book.sells.count ? book.sells[row] : nil
            cell.process((buy,sell))
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
    func process(_ x:(buy:State.Order?, sell:State.Order?)) {
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

