import Foundation

extension Optional {
  func or(_ value: @autoclosure () -> Wrapped) -> Wrapped {
    switch self {
    case let .some(value): return value
    case .none: return value()
    }
  }

  func or(throw error: @autoclosure () -> Error) throws -> Wrapped {
    switch self {
    case let .some(value): return value
    case .none: throw error()
    }
  }
}
