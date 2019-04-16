import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct StoriesViewModel {
  struct Story: Equatable {
    let id: Int
    let title: String
    let user: String
    let score: Int
    let comments: Int
  }

  typealias SectionModel = AnimatableSectionModel<Int, Story>

  let selectedStory = PublishRelay<IndexPath>()

  private let repository: Repository
  private let stories: Observable<LoadingState<[FirebaseItem]>>

  init(repository: Repository) {
    self.repository = repository
    self.stories = repository.fetchTopStories()
      .asObservable()
      .toLoadingState()
      .share(replay: 1)
  }

  var title: Driver<String> {
    return .just("Top Stories")
  }

  var nextViewModel: Driver<CommentsViewModel> {
    return selectedStory
      .withLatestFrom(stories) { index, stories -> FirebaseItem? in
        guard let values = stories.value else {
          return nil
        }
        return values[index.row]
      }
      .flatMapLatest { [repository] item -> Observable<CommentsViewModel> in
        guard let item = item else {
          return .empty()
        }
        return .just(CommentsViewModel(item: item, repository: repository))
      }
      .asDriver(onErrorDriveWith: .empty())
  }

  var topStories: Driver<[SectionModel]> {
    return stories.value()
      .map { items in
        items.map(Story.init)
      }
      .map { stories in
        [SectionModel(model: 0, items: stories)]
      }
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

extension StoriesViewModel.Story: IdentifiableType {
  typealias Identity = Int

  var identity: Int {
    return id
  }
}
