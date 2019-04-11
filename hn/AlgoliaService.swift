import Foundation
import ReactiveKit

class AlgoliaService {
  private let apiClient: APIClient
  private let decoder = JSONDecoder()

  init(apiClient: APIClient = APIClient()) {
    self.apiClient = apiClient
  }

  func item(id: Int) -> Signal<Item, APIError> {
    return apiClient.get(Algolia.item(id).url).compactMap { [decoder] response in
      guard (200..<299).contains(response.statusCode), let data = response.body else {
        return nil
      }
      do {
        return try decoder.decode(data)
      } catch {
        return nil
      }
    }
  }
}
