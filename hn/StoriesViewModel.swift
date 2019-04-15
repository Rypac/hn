import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct StoriesViewModel {
  struct StorySection {
    var items: [Story]
  }

  struct Story {
    let id: Int
    let title: String
    let user: String
    let score: Int
    let comments: Int
  }

  let selectedStory = PublishRelay<IndexPath>()

  private let storyRepostiory: Repository
  private let stories: Observable<LoadingState<[FirebaseItem]>>

  init(storyRepostiory: Repository = Repository()) {
    self.storyRepostiory = storyRepostiory
    self.stories = storyRepostiory.fetchTopStories()
      .asObservable()
      .toLoadingState()
      .share(replay: 1)
  }

  var nextViewModel: Driver<CommentsViewModel> {
    return selectedStory
      .withLatestFrom(stories) { index, stories -> FirebaseItem? in
        guard let values = stories.value else {
          return nil
        }
        return values[index.row]
      }
      .flatMapLatest { [storyRepostiory] item -> Observable<CommentsViewModel> in
        guard let item = item else {
          return .empty()
        }
        return .just(CommentsViewModel(item: item, repository: storyRepostiory))
      }
      .asDriver(onErrorDriveWith: .empty())
  }

  var topStories: Driver<[StorySection]> {
    return stories.value()
      .map { items in
        items.map(Story.init)
      }
      .map { [StorySection(items: $0)] }
      .asDriver(onErrorJustReturn: [])
  }

  var loading: Driver<Bool> {
    return stories.isLoading()
      .asDriver(onErrorJustReturn: false)
  }
}

private extension StoriesViewModel.Story {
  init(item: FirebaseItem) {
    id = item.id
    title = item.title ?? ""
    user = item.author ?? ""
    score = item.score ?? 0
    comments = item.descendants ?? 0
  }
}

private extension CommentsViewModel {
  init(item: FirebaseItem, repository: Repository) {
    self.init(
      post: Post(
        id: item.id,
        title: item.title ?? "",
        url: item.url ?? "",
        text: item.text?.strippingHtmlElements().text ?? "",
        user: item.author ?? "",
        score: item.score ?? 0),
      repository: repository
    )
  }
}

extension StoriesViewModel.StorySection: SectionModelType {
  typealias Item = StoriesViewModel.Story

  init(original: StoriesViewModel.StorySection, items: [StoriesViewModel.Story]) {
    self = original
    self.items = items
  }
}
