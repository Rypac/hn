import Foundation
import ReactiveKit

extension APIClient {
  func get(_ url: URL) -> Signal<APIResponse<Data?>, APIError> {
    return Signal { [weak self] observer in
      let task = self?.get(url) { result in
        switch result {
        case .success(let response):
          observer.next(response)
          observer.completed()
        case .failure(let error):
          observer.failed(error)
        }
      }

      return BlockDisposable {
        task?.cancel()
      }
    }
  }
}
