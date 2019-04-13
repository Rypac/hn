import UIKit

final class FullWidthFlowLayout: UICollectionViewFlowLayout {
  override init() {
    super.init()
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    estimatedItemSize = UICollectionViewFlowLayout.automaticSize
  }

  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard
      let layoutAttributes = super.layoutAttributesForItem(at: indexPath),
      let collectionView = collectionView
    else {
      return nil
    }

    let horizontalInset = sectionInset.left + sectionInset.right
    layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - horizontalInset
    return layoutAttributes
  }

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else {
      return nil
    }
    guard scrollDirection == .vertical else {
      return layoutAttributes
    }

    return layoutAttributes.compactMap { layoutAttribute in
      layoutAttribute.representedElementCategory == .cell
        ? layoutAttributesForItem(at: layoutAttribute.indexPath)
        : layoutAttribute
    }
  }

  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
}
