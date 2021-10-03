import Foundation
import UIKit

extension Shell {
    static func recentTradeList() -> UIViewController & RecentTradeListShellIO {
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
        return RecentTradeListShellImpl(collectionViewLayout: layout)
    }
}
protocol RecentTradeListShellIO {
    func process(_ x:Rendition)
    func dispatch(_ fx:@escaping(Action) -> Void)
}

private final class RecentTradeListShellImpl: UICollectionViewController, RecentTradeListShellIO {
    private var rendition = Rendition()
    private var broadcast = noop as (Action) -> Void
    func process(_ x: Rendition) {
        rendition = x
        collectionView.reloadData()
    }
    func dispatch(_ fx: @escaping (Action) -> Void) {
        broadcast = fx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(TradeRecordCell.self, forCellWithReuseIdentifier: TradeRecordCell.reuseID)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rendition.orderBook.items.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TradeRecordCell.reuseID, for: indexPath)
        if let cell = cell as? TradeRecordCell {
            let rend = rendition.recentTrade.items[indexPath.row]
            cell.process(rend)
        }
        return cell
    }
}

private final class TradeRecordCell: UICollectionViewCell {
    static var reuseID: String { NSStringFromClass(self) }
    func process(_ x:State.Trade) {
        
    }
}
