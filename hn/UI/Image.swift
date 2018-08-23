import UIKit

protocol ImageSet {
  var image: UIImage { get }
}

enum Icon {
  case newStories
  case topStories
  case bestStories
  case askHN
  case showHN
}

extension Icon: ImageSet {
  var image: UIImage {
    switch self {
    case .newStories: return #imageLiteral(resourceName: "TabBarNewStories")
    case .topStories: return #imageLiteral(resourceName: "TabBarTopStories")
    case .bestStories: return #imageLiteral(resourceName: "TabBarBestStories")
    case .askHN: return #imageLiteral(resourceName: "TabBarAskHN")
    case .showHN: return #imageLiteral(resourceName: "TabBarShowHN")
    }
  }
}
