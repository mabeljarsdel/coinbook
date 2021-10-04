//import Foundation
//import UIKit
//
//extension Shell {
//    static func orderBook2() -> UIViewController & OrderBook2IO { OrderBook2Impl() }
//}
//protocol OrderBook2IO {
//    func process(_ x:Rendition)
//    func dispatch(_ fx:@escaping(Action) -> Void)
//}
//
//private final class OrderBook2Impl: UIViewController, OrderBook2IO {
//    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
//    private var dataSource = UICollectionViewDiffableDataSource<Int,Int>?.none
//    private var state = State()
//    private var broadcast = noop as (Action) -> Void
//    private var isInstalled = false
//    func process(_ x:Rendition) {
//        guard let x = x.state else { return }
//        if !isInstalled {
//            isInstalled = true
//            loadViewIfNeeded()
//            view.addSubview(collectionView)
//            collectionView.backgroundColor = .white
//            collectionView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            ])
//            collectionView.register(OrderBookItemCell.self, forCellWithReuseIdentifier: OrderBookItemCell.reuseID)
//            dataSource = UICollectionViewDiffableDataSource(
//                collectionView: collectionView,
//                cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
//                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderBookItemCell.reuseID, for: indexPath)
//                    if let cell = cell as? OrderBookItemCell {
//                        if let book = self?.state.orderBook {
//                            let row = indexPath.row
//                            let buy = row < book.buys.count ? book.buys[row] : nil
//                            let sell = row < book.sells.count ? book.sells[row] : nil
//                            cell.process((buy,sell))
//                        }
//                    }
//                    return cell
//                })
//            collectionView.dataSource = dataSource
//        }
//        state = x
//        var snapshot = NSDiffableDataSourceSnapshot<Int,Int>()
//        snapshot.appendSections([0])
//        let n = max(state.orderBook.buys.count, state.orderBook.sells.count)
//        snapshot.appendItems(Array(0..<n), toSection: 0)
//        dataSource?.apply(snapshot)
//    }
//    func dispatch(_ fx: @escaping (Action) -> Void) {
//        broadcast = fx
//    }
//}
//
//private final class OrderBookItemCell: UICollectionViewCell {
//    static var reuseID: String { NSStringFromClass(self) }
//    
//    private let buyQuantityLabel = UILabel()
//    private let buyPriceLabel = UILabel()
//    private let sellQuantityLabel = UILabel()
//    private let sellPriceLabel = UILabel()
//    private var isInstalled = false
//    func process(_ x:(buy:State.Order?, sell:State.Order?)) {
//        if !isInstalled {
//            isInstalled = true
//            contentView.addSubview(buyQuantityLabel)
//            contentView.addSubview(buyPriceLabel)
//            contentView.addSubview(sellPriceLabel)
//            contentView.addSubview(sellQuantityLabel)
//            buyQuantityLabel.translatesAutoresizingMaskIntoConstraints = false
//            buyPriceLabel.translatesAutoresizingMaskIntoConstraints = false
//            sellPriceLabel.translatesAutoresizingMaskIntoConstraints = false
//            sellQuantityLabel.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                buyQuantityLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
//                buyPriceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
//                contentView.leadingAnchor.constraint(equalTo: buyQuantityLabel.leadingAnchor),
//                buyQuantityLabel.trailingAnchor.constraint(equalTo: buyPriceLabel.leadingAnchor),
//                contentView.topAnchor.constraint(equalTo: buyQuantityLabel.topAnchor),
//                contentView.bottomAnchor.constraint(equalTo: buyQuantityLabel.bottomAnchor),
//                contentView.topAnchor.constraint(equalTo: buyPriceLabel.topAnchor),
//                contentView.bottomAnchor.constraint(equalTo: buyPriceLabel.bottomAnchor),
//                
//                sellPriceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
//                sellQuantityLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
//                sellPriceLabel.trailingAnchor.constraint(equalTo: sellQuantityLabel.leadingAnchor),
//                sellQuantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//                contentView.topAnchor.constraint(equalTo: sellQuantityLabel.topAnchor),
//                contentView.bottomAnchor.constraint(equalTo: sellQuantityLabel.bottomAnchor),
//                contentView.topAnchor.constraint(equalTo: sellPriceLabel.topAnchor),
//                contentView.bottomAnchor.constraint(equalTo: sellPriceLabel.bottomAnchor),
//            ])
//            buyPriceLabel.textAlignment = .right
//            sellQuantityLabel.textAlignment = .right
//        }
//        
//        buyQuantityLabel.text = x.buy?.quantity.description ?? "????"
//        buyPriceLabel.text = x.buy?.price.description ?? "????"
//        sellQuantityLabel.text = x.sell?.quantity.description ?? "????"
//        sellPriceLabel.text = x.sell?.price.description ?? "????"
//    }
//}
//
//
//private extension State {
//    func renditionForRow(_ row:Int) -> (buy:State.Order?, sell:State.Order?) {
//        let book = orderBook
//        let buy = row < book.buys.count ? book.buys[row] : nil
//        let sell = row < book.sells.count ? book.sells[row] : nil
//        return (buy,sell)
//    }
//}
//
//private func makeLayout() -> UICollectionViewCompositionalLayout {
//    let cellSize = NSCollectionLayoutSize(
//        widthDimension: .fractionalWidth(1),
//        heightDimension: .absolute(44))
//    let layout = UICollectionViewCompositionalLayout(
//        section: NSCollectionLayoutSection(
//            group: NSCollectionLayoutGroup.vertical(
//                layoutSize: cellSize,
//                subitems: [
//                    NSCollectionLayoutItem(layoutSize: cellSize),
//                ])))
//    return layout
//}
