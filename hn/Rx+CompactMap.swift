import RxSwift

extension ObservableType {
  public func compactMap<R>(_ transform: @escaping (E) throws -> R?) -> Observable<R> {
    return map(transform)
      .filter { $0 != nil }
      .map { $0! }
  }
}
