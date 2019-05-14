import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct CommentsViewModel {
  enum Section: Int {
    case post
    case comments
    case loading
  }
  enum Row {
    case post(Post)
    case comment(Comment)
    case loading
  }

  struct Post: Equatable {
    let id: Int
    let title: String
    let url: String
    let text: String
    let user: String
    let score: Int
  }
  struct Comment: Equatable {
    let id: Int
    let text: String
    let user: String
    let score: Int
    let depth: Int
  }

  typealias SectionModel = AnimatableSectionModel<Section, Row>

  let refresh = PublishRelay<Void>()
  let viewStory = PublishRelay<Void>()

  private let post: Post
  private let itemAndComments: Observable<LoadingState<AlgoliaItem>>

  init(post: Post, services: Services) {
    self.post = post
    self.itemAndComments = refresh
      .startWith(())
      .flatMapLatest {
        services.algolia.item(id: post.id)
          .asObservable()
          .toLoadingState()
      }
      .share()
  }

  var title: Driver<String> {
    return .just("Comments")
  }

  var comments: Driver<[SectionModel]> {
    return itemAndComments
      .value()
      .map { item in
        let (post, comments) = item.extractPostAndComments()
        return [
          SectionModel(model: .post, items: [.post(post)]),
          SectionModel(model: .comments, items: comments.map(Row.comment))
        ]
      }
      .startWith([
        SectionModel(model: .post, items: [.post(post)]),
        SectionModel(model: .loading, items: [.loading])
      ])
      .asDriver(onErrorDriveWith: .empty())
  }

  var loading: Driver<Bool> {
    return itemAndComments.isLoading()
      .asDriver(onErrorJustReturn: false)
  }

  var url: Driver<URL> {
    return viewStory.withLatestFrom(itemAndComments)
      .value()
      .compactMap { item in
        URL(string: Post(item: item).url)
      }
      .asDriver(onErrorDriveWith: .empty())
  }
}

extension CommentsViewModel.Section: IdentifiableType {
  var identity: Int {
    return rawValue
  }
}

extension CommentsViewModel.Row: IdentifiableType, Equatable {
  var identity: Int {
    switch self {
    case let .comment(comment): return comment.id
    case let .post(post): return post.id
    case .loading: return 0
    }
  }
}

private extension AlgoliaItem {
  typealias Post = CommentsViewModel.Post
  typealias Comment = CommentsViewModel.Comment

  func extractPostAndComments() -> (Post, [Comment]) {
    return (Post(item: self), flattenKids().map { Comment(item: $0, depth: $1) }.compactMap { $0 })
  }

  private func flattenKids() -> [(AlgoliaItem, Int)] {
    func flattenResponses(_ item: AlgoliaItem, depth: Int) -> [(AlgoliaItem, Int)] {
      return [(item, depth)] + (item.children?.flatMap { kid in flattenResponses(kid, depth: depth + 1) } ?? [])
    }
    return children?.flatMap { kid in flattenResponses(kid, depth: 0) } ?? []
  }
}

private extension CommentsViewModel.Post {
  init(item: AlgoliaItem) {
    id = item.id
    title = item.title ?? ""
    url = item.url ?? ""
    text = item.text?.strippingHtmlElements().text ?? ""
    user = item.author ?? ""
    score = item.points ?? 0
  }
}

private extension CommentsViewModel.Comment {
  init(item: AlgoliaItem, depth: Int) {
    id = item.id
    text = item.text?.strippingHtmlElements().text ?? ""
    user = item.author ?? "deleted"
    score = item.points ?? 0
    self.depth = depth
  }
}
