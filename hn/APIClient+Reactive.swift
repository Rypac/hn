import Foundation
import RxSwift

extension APIClient {
  func get(_ url: URL) -> Single<APIResponse<Data?>> {
    return .create { [weak self] observer in
      let task = self?.get(url) { result in
        switch result {
        case .success(let response):
          observer(.success(response))
        case .failure(let error):
          observer(.error(error))
        }
      }

      return Disposables.create {
        task?.cancel()
      }
    }
  }
}
