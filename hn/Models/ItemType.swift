import UIKit

enum ItemType {
    case topStories
    case newStories
    case bestStories
    case showHN
    case askHN
    case jobs
    case updates
}

extension ItemType: CustomStringConvertible {
    var description: String {
        switch self {
        case .topStories: return "Top Stories"
        case .newStories: return "New Stories"
        case .bestStories: return "Best Stories"
        case .showHN: return "Show HN"
        case .askHN: return "Ask HN"
        case .jobs: return "Jobs"
        case .updates: return "Updates"
        }
    }
}

extension ItemType: ImageSet {
    var image: UIImage {
        switch self {
        case .newStories: return Icon.newStories.image
        case .bestStories: return Icon.bestStories.image
        case .topStories: return Icon.topStories.image
        case .askHN: return Icon.askHN.image
        case .showHN: return Icon.showHN.image
        default: return Icon.showHN.image
        }
    }
}
