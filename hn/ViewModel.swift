import Foundation
import ReactiveKit

struct ViewModel {
  struct Story {
    let title: String?
    let user: String?
    let score: Int?
  }

  let storyRepostiory: StoryRepository

  init(storyRepostiory: StoryRepository = StoryRepository()) {
    self.storyRepostiory = storyRepostiory
  }

  var topStories: LoadingSignal<[Story], APIError> {
    return storyRepostiory.fetchTopStories().mapValue { items in
      items.map { Story(title: $0.title, user: $0.author, score: $0.score) }
    }
  }
}
