import UIKit

internal final class CalandarWeeklyLayout: UICollectionViewLayout {

    private var allAttributes: [[UICollectionViewLayoutAttributes]] = []

    private var contentSize: CGSize = .zero

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        allAttributes.removeAll(keepingCapacity: true)
    }

    override func prepare() {
        updateAttributes()
        stickyTopItems()

        let allFrames = allAttributes
            .flatMap({ $0 })
            .map({ $0.frame })
        let maxX = allFrames.map({ $0.maxX }).max() ?? .zero
        let maxY = allFrames.map({ $0.maxY }).max() ?? .zero
        contentSize = CGSize(width: maxX, height: maxY)
    }

    private func updateAttributes() {
        guard let collectionView = collectionView else {
            return
        }

        var xOffset: CGFloat = 0

        for section in 0..<collectionView.numberOfSections {
            var rowAttributes: [UICollectionViewLayoutAttributes] = []

            var yOffset: CGFloat = 0
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let itemSize = size(forItem: item)
                let indexPath: IndexPath = .init(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral

                rowAttributes.append(attributes)

                yOffset += itemSize.height
            }
            xOffset += rowAttributes.first?.frame.width ?? 0.0
            allAttributes.append(rowAttributes)
        }
    }

    private func size(forItem item: Int) -> CGSize {
        let width: CGFloat = (collectionView?.frame.width ?? .zero) / 4.6
        if item == 0 {
            return .init(width: width, height: 60)
        }
        return .init(width: width, height: 40)
    }

    private func stickyTopItems() {
        guard let collectionView = collectionView else {
            return
        }
        allAttributes
            .compactMap({ $0.first })
            .forEach {
                $0.zIndex = .max
                var frame = $0.frame
                frame.origin.y += collectionView.contentOffset.y
                $0.frame = frame
            }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        allAttributes
            .flatMap({ $0 })
            .filter({ rect.intersects($0.frame) })
    }
}
