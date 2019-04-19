import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct StoriesViewModel {
  enum Section: Int {
    case stories
    case nextPage
  }

  enum Row {
    case story(Story)
    case nextPage
  }

  struct Story {
    let id: Int
    let title: String
    let user: String
    let score: Int
    let comments: Int
  }

  typealias SectionModel = AnimatableSectionModel<Section, Row>
  private typealias Batch<T> = (remaining: [T], next: [T])

  let refresh = PublishRelay<Void>()
  let selectedStory = PublishRelay<IndexPath>()
  let fetchNextStories = PublishRelay<[IndexPath]>()

  private let services: Services
  private let items: Observable<[Int]>
  private let stories: Observable<LoadingState<[FirebaseItem]>>
  private let hasMore: Observable<Bool>

  init(services: Services) {
    self.services = services

    let batch = 25

    let refreshTrigger = refresh
      .startWith(())

    self.items = refreshTrigger
      .flatMapLatest {
        services.firebase.topStories()
      }
      .share()

    let nextPage = fetchNextStories
      .filter { $0.contains(where: { $0.section == Section.nextPage.rawValue }) }
      .map { _ in }
      .startWith(())

    let pagedItems = items
      .flatMapLatest { items -> Observable<Batch<Int>> in
        nextPage
          .scan((remaining: items, next: [])) { state, _ in
            let (remaining, _) = state
            let size = remaining.count > batch ? batch : remaining.count
            guard size > 0 else {
              return ([], [])
            }
            return (
              remaining: Array(remaining.dropFirst(size)),
              next: Array(remaining.prefix(size))
            )
          }
      }
      .share()

    self.hasMore = pagedItems
      .map { !$0.remaining.isEmpty }

    self.stories = refreshTrigger
      .flatMapLatest {
        pagedItems
          .filter { !$0.next.isEmpty }
          .map { $0.next }
          .flatMapLatest { [services] ids -> Observable<[FirebaseItem]> in
            Observable.from(ids.map(services.firebase.item(id:)))
              .merge()
              .toArray()
              .map { items in
                items
                  .filter { $0.isAlive }
                  .sorted(relativeTo: ids, selector: { $0.id })
              }
          }
          .scan([], accumulator: +)
          .toLoadingState()
      }
      .share()
  }
}

extension StoriesViewModel {
  var title: Driver<String> {
    return .just("Top Stories")
  }

  var nextViewModel: Driver<CommentsViewModel> {
    return selectedStory
      .withLatestFrom(stories.value()) { index, stories -> FirebaseItem? in
        guard index.section == Section.stories.rawValue else {
          return nil
        }
        return stories[index.row]
      }
      .flatMapLatest { [services] item -> Observable<CommentsViewModel> in
        guard let item = item else {
          return .empty()
        }
        return .just(CommentsViewModel(item: item, services: services))
      }
      .asDriver(onErrorDriveWith: .empty())
  }

  var topStories: Driver<[SectionModel]> {
    return stories.value()
      .withLatestFrom(hasMore) { ($0, $1) }
      .map { items, hasMore in
        let stories = SectionModel(model: .stories, items: items.map { .story(Story(item: $0)) })
        let loading = hasMore ? SectionModel(model: .nextPage, items: [.nextPage]) : nil
        return [stories, loading].compactMap { $0 }
      }
      .asDriver(onErrorJustReturn: [])
  }

  var loading: Driver<Bool> {
    return stories.isLoading()
      .asDriver(onErrorJustReturn: false)
  }
}

private extension FirebaseItem {
  var isAlive: Bool {
    guard let dead = dead, let deleted = deleted else {
      return true
    }
    return !dead && !deleted
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
  init(item: FirebaseItem, services: Services) {
    self.init(
      post: Post(
        id: item.id,
        title: item.title ?? "",
        url: item.url ?? "",
        text: item.text?.strippingHtmlElements().text ?? "",
        user: item.author ?? "",
        score: item.score ?? 0),
      services: services
    )
  }
}

extension StoriesViewModel.Section: IdentifiableType, Equatable {
  var identity: Int {
    return rawValue
  }
}

extension StoriesViewModel.Row: IdentifiableType, Equatable {
  var identity: Int {
    switch self {
    case let .story(story): return story.identity
    case .nextPage: return 0
    }
  }
}

extension StoriesViewModel.Story: IdentifiableType, Equatable {
  var identity: Int {
    return id
  }
}

private extension Sequence {
  func sorted<C, Key>(relativeTo other: C, selector: (Element) -> Key) -> [Element] where C: Collection, C.Element == Key, Key: Equatable {
    return sorted { a, b in
      if let first = other.firstIndex(of: selector(a)), let second = other.firstIndex(of: selector(b)) {
        return first < second
      }
      return false
    }
  }
}
