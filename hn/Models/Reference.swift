import Foundation

typealias Id = Int

enum Reference<T> {
  case id(Id)
  case value(T)
}

extension Reference {
  func bindValue<U>(_ transform: (T) -> U?) -> U? {
    switch self {
    case .id: return .none
    case let .value(val): return transform(val)
    }
  }

  func bindId<U>(_ transform: (Id) -> U?) -> U? {
    switch self {
    case let .id(id): return transform(id)
    case .value: return .none
    }
  }
}

extension Reference where T == Item {
  var id: Id {
    switch self {
    case let .id(id): return id
    case let .value(item): return item.id
    }
  }
}
