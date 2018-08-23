import Foundation

enum AsyncRequestState<T> {
  case none
  case request
  case success(result: T)
  case error(error: Error)
}
