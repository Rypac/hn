import Foundation
import RxSwift

class FirebaseService {
  typealias Item = FirebaseItem

  private let apiClient: APIClient
  private let decoder = JSONDecoder()

  init(apiClient: APIClient = APIClient()) {
    self.apiClient = apiClient
  }

  func topStories() -> Single<[Int]> {
    return apiClient.get(Firebase.topStories.url)
      .map { [decoder] response in
        guard (200..<299).contains(response.statusCode) else {
          throw APIServiceError.invalidStatusCode
        }
        guard let data = response.body else {
          throw APIServiceError.invalidPayload
        }
        return try decoder.decode(data)
      }
  }

  func item(id: Int) -> Single<Item> {
    return apiClient.get(Firebase.item(id).url)
      .map { [decoder] response in
        guard (200..<299).contains(response.statusCode) else {
          throw APIServiceError.invalidStatusCode
        }
        guard let data = response.body else {
          throw APIServiceError.invalidPayload
        }
        return try decoder.decode(data)
      }
  }
}
