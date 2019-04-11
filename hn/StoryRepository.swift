import Foundation
import ReactiveKit

class StoryRepository {
  let topStories: LoadingProperty<[Item], APIError>

  init(storyService: FirebaseService = FirebaseService(), algoliaService: AlgoliaService = AlgoliaService()) {
    topStories = LoadingProperty {
      storyService.topStories()
        .flatMapLatest { (items: [Int]) -> Signal<[Item], APIError> in
          let firstTenStories = items.prefix(20).map(algoliaService.item(id:))
          return Signal(combiningLatest: firstTenStories, combine: { $0 })
        }
        .toLoadingSignal()
    }
  }

  func fetchTopStories() -> LoadingSignal<[Item], APIError> {
    return topStories.reload()
  }
}
