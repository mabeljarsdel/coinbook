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
        collectionView.register(TradeRecordCell.self, forCellWithReuseIdentifier: TradeRecordCell.reuseID)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        state.trades.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TradeRecordCell.reuseID, for: indexPath)
        if let cell = cell as? TradeRecordCell {
            let trade = state.trades[indexPath.row]
            cell.process(trade)
        }
        return cell
    }
}

private final class TradeRecordCell: UICollectionViewCell {
    static var reuseID: String { NSStringFromClass(self) }
    func process(_ x:State.Trade) {
        
    }
}
