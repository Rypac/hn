import Foundation
import ReactiveKit

class FirebaseService {
  private let apiClient: APIClient
  private let decoder = JSONDecoder()

  init(apiClient: APIClient = APIClient()) {
    self.apiClient = apiClient
  }

  func topStories() -> Signal<[Int], APIError> {
    return apiClient.get(Firebase.topStories.url).map { [decoder] response in
      guard (200..<299).contains(response.statusCode), let data = response.body else {
        return []
      }
      do {
        return try decoder.decode(data)
      } catch {
        return []
      }
    }
  }
}
