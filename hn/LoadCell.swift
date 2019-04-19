import UIKit

final class LoadingCell: UITableViewCell {
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!
}

extension LoadingCell {
  func load() {
    activityIndicator.startAnimating()
  }
}

extension LoadingCell: ReusableCell {
  static var reuseIdentifier: String {
    return "LoadingCell"
  }
}
