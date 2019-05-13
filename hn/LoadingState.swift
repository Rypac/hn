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
  func toLoadingState() -> Observable<LoadingState<Element>> {
    return map(LoadingState.loaded)
      .catchError { .just(.failed($0)) }
      .startWith(.loading)
  }
}

extension ObservableType {
  func value<Element>() -> Observable<Element> where Self.Element == LoadingState<Element> {
    return compactMap { $0.value }
  }

  func mapValue<Element, Result>(_ transform: @escaping (Element) -> Result) -> Observable<LoadingState<Result>> where Self.Element == LoadingState<Element> {
    return map { loadingState in
      switch loadingState {
      case let .loaded(value): return .loaded(transform(value))
      case let .failed(error): return .failed(error)
      case .loading: return .loading
      }
    }
  }

  func isLoading<Element>() -> Observable<Bool> where Self.Element == LoadingState<Element> {
    return map { loadingState in
      guard case .loading = loadingState else {
        return false
      }
      return true
    }
  }
}
