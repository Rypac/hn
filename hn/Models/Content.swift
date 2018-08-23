import Foundation

enum Content<T> {
  case dead
  case deleted
  case details(T)
}

extension Content {
  var details: T? {
    switch self {
    case let .details(details): return details
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

extension Content where T: Equatable {
  static func == (_ lhs: Content, _ rhs: Content) -> Bool {
    switch (lhs, rhs) {
    case (.dead, .dead), (.deleted, .deleted):
      return true
    case let (.details(lhs), .details(rhs)):
      return lhs == rhs
    case (.dead, _), (.deleted, _), (.details, _):
      return false
    }
  }
}
