import UIKit

protocol CellReusable {
  static var reuseIdentifier: String { get }
}

extension UICollectionView {
  func dequeueReusableCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell & CellReusable {
    return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
}
