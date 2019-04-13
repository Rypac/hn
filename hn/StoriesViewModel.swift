import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct StoriesViewModel {
  struct StorySection {
    var items: [Story]
  }

  struct Story {
    let title: String
    let user: String
    let score: Int
  }

  let storyRepostiory: Repository

  private let stories: Observable<LoadingState<[Item]>>

  init(storyRepostiory: Repository = Repository()) {
    self.storyRepostiory = storyRepostiory
    self.stories = storyRepostiory.fetchTopStories()
      .asObservable()
      .toLoadingState()
      .share(replay: 1)
  }

  var topStories: Driver<[StorySection]> {
    return stories.value()
      .map { items in
        items.map { Story(title: $0.title ?? "", user: $0.author ?? "", score: $0.score ?? 0) }
      }
      .map { [StorySection(items: $0)] }
      .asDriver(onErrorJustReturn: [])
  }

  var loading: Driver<Bool> {
    return stories.isLoading()
      .asDriver(onErrorJustReturn: false)
  }
}

extension StoriesViewModel.StorySection: SectionModelType {
  typealias Item = StoriesViewModel.Story

  init(original: StoriesViewModel.StorySection, items: [StoriesViewModel.Story]) {
    self = original
    self.items = items
  }
}
