import Foundation
import RxSwift

enum LoadingState<Value> {
  case loading
  case loaded(Value)
  case failed(Error)
}

extension LoadingState {
  var value: Value? {
    switch self {
    case let .loaded(value): return value
    case .loading, .failed: return nil
    }
  }
}

extension ObservableType {
  func toLoadingState() -> Observable<LoadingState<E>> {
    return map(LoadingState.loaded)
      .catchError { .just(.failed($0)) }
      .startWith(.loading)
  }
}

extension ObservableType {
  func value<E>() -> Observable<E> where Self.E == LoadingState<E> {
    return compactMap { $0.value }
  }

  func mapValue<E, R>(_ transform: @escaping (E) -> R) -> Observable<LoadingState<R>> where Self.E == LoadingState<E> {
    return map { loadingState in
      switch loadingState {
      case let .loaded(value): return .loaded(transform(value))
      case let .failed(error): return .failed(error)
      case .loading: return .loading
      }
    }
  }

  func isLoading<E>() -> Observable<Bool> where Self.E == LoadingState<E> {
    return map { loadingState in
      guard case .loading = loadingState else {
        return false
      }
      return true
    }
  }
}
