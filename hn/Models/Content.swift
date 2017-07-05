import Foundation

enum Content<T> {
    case dead
    case deleted
    case details(T)
}

extension Content {
    var details: T? {
        switch self {
        case .details(let details): return details
        default: return nil
        }
    }
}

extension Content where T: ItemInitialisable {
    init?(fromItem item: Item) {
        switch (item.deleted, item.dead) {
        case (true, _):
            self = .deleted
        case (_, true):
            self = .dead
        default:
            guard let val = T(fromItem: item) else {
                return nil
            }
            self = .details(val)
        }
    }
}
