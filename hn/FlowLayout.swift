import UIKit

final class FlowLayout: UICollectionViewFlowLayout {
  override init() {
    super.init()
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    minimumInteritemSpacing = 10
    minimumLineSpacing = 10
    sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    estimatedItemSize = UICollectionViewFlowLayout.automaticSize
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard
      let layoutAttributes = super.layoutAttributesForItem(at: indexPath),
      let collectionView = collectionView
    else {
      return nil
    }

    layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
    return layoutAttributes
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else {
      return nil
    }
    guard scrollDirection == .vertical else {
      return superLayoutAttributes
    }

    return superLayoutAttributes.compactMap { layoutAttribute in
      layoutAttribute.representedElementCategory == .cell
        ? layoutAttributesForItem(at: layoutAttribute.indexPath)
        : layoutAttribute
    }
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let view = collectionView else {
      return false
    }
    return view.bounds.width != newBounds.width
  }
}
