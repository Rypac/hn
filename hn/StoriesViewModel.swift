import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct StoriesViewModel {
  struct Story {
    let id: Int
    let title: String
    let user: String
    let score: Int
    let comments: Int
  }

  typealias SectionModel = AnimatableSectionModel<Int, Story>
  private typealias BatchedItems = (remaining: [Int], next: [Int])

  let refresh = PublishRelay<Void>()
  let selectedStory = PublishRelay<IndexPath>()
  let fetchNextStories = PublishRelay<[IndexPath]>()

  private let services: Services
  private let stories: Observable<LoadingState<[FirebaseItem]>>

  init(services: Services) {
    self.services = services

    let stories = services.firebase.topStories()
      .asObservable()
      .flatMap { [fetchNextStories] items -> Observable<[FirebaseItem]> in
        fetchNextStories
          .compactMap { $0.last?.row }
          .startWith(0)
          .batch(items, into: 15)
          .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
          .flatMapLatest { batchedItems -> Single<[FirebaseItem]> in
            Observable.from(batchedItems.map(services.firebase.item(id:)))
              .merge()
              .toArray()
              .map { stories in stories
                .filter { $0.isAlive }
                .sorted(relativeTo: items, selector: { $0.id })
              }
              .asSingle()
          }
          .scan([], accumulator: +)
      }

    self.stories = refresh
      .startWith(())
      .flatMapLatest {
        stories.toLoadingState()
      }
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

extension StoriesViewModel.Story: IdentifiableType, Equatable {
  typealias Identity = Int

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

private extension Observable where Element == Int {
  func batch<T>(_ items: [T], into batch: Int) -> Observable<[T]> {
    return self
      .scan((remaining: items, next: [], previous: 0)) { aggregate, index in
        let (remaining, _, previous) = aggregate
        let next = index + 1
        guard next >= previous, next < items.count else {
          return (remaining, [], previous)
        }

        let size = remaining.count > batch ? batch : remaining.count
        return (
          Array(remaining.suffix(from: size)),
          Array(remaining.prefix(size)),
          index + size
        )
      }
      .filter { !$0.next.isEmpty }
      .map { $0.next }
  }
}
