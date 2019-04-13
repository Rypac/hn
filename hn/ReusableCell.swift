import UIKit

protocol ReusableCell: UIView {
  static var reuseIdentifier: String { get }
}

extension UICollectionView {
  func dequeueReusableCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell & ReusableCell {
    return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
}

extension UITableView {
  func dequeueReusableCell<T>(ofType type: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell & ReusableCell {
    return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
  }
}
