import Foundation
import RxCocoa
import RxDataSources
import RxSwift

struct CommentsViewModel {
  enum Cell {
    case post(Post)
    case comment(Comment)
  }
  struct Post {
    let id: Int
    let title: String
    let url: String
    let text: String
    let user: String
    let score: Int
  }
  struct Comment {
    let id: Int
    let text: String
    let user: String
    let score: Int
    let depth: Int
  }

  typealias SectionModel = AnimatableSectionModel<Int, Cell>

  let refresh = PublishRelay<Void>()

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
      .share(replay: 1)
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
          SectionModel(model: 0, items: [.post(post)]),
          SectionModel(model: 1, items: comments.map(Cell.comment))
        ]
      }
      .startWith([
        SectionModel(model: 0, items: [.post(post)])
      ])
      .asDriver(onErrorDriveWith: .empty())
  }

  var loading: Driver<Bool> {
    return itemAndComments.isLoading()
      .asDriver(onErrorJustReturn: false)
  }
}

extension CommentsViewModel.Cell: IdentifiableType, Equatable {
  typealias Identity = Int

  var identity: Int {
    switch self {
    case .comment: return 0
    case .post: return 1
    }
  }
}

extension CommentsViewModel.Post: IdentifiableType, Equatable {
  var identity: Int {
    return id
  }
}

extension CommentsViewModel.Comment: IdentifiableType, Equatable {
  var identity: Int {
    return id
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
    user = item.author ?? ""
    score = item.points ?? 0
    self.depth = depth
  }
}
