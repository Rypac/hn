import UIKit

extension IndexPath {
  func `as`<T: RawRepresentable>(_: T.Type) -> T? where T.RawValue == Int {
    return T(rawValue: section)
  }
}

extension UIEdgeInsets {
  init(all margin: CGFloat) {
    self.init(top: margin, left: margin, bottom: margin, right: margin)
  }

  init(horizontal: CGFloat, vertical: CGFloat) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }

  struct Default {
    static let vertical: CGFloat = 8
    static let horizontal: CGFloat = 15

    static let tableViewCell = UIEdgeInsets(horizontal: horizontal, vertical: vertical)
  }
}
