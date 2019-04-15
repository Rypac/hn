import Foundation

struct AlgoliaItem: Decodable {
  typealias Id = Int

  enum PostType: String, Decodable {
    case story
    case comment
    case job
    case poll
    case pollOption

    enum CodingKeys: String, CodingKey {
      case story = "story"
      case comment = "comment"
      case job = "job"
      case poll = "poll"
      case pollOption = "pollopt"
    }
  }

  let id: Id
  let type: PostType
  let title: String?
  let text: String?
  let points: Int?
  let author: String?
  let time: Int?
  let url: String?
  let parent: Int?
  let children: [AlgoliaItem]?

  init(
    id: Int,
    type: PostType,
    title: String?,
    text: String?,
    points: Int?,
    author: String?,
    time: Int?,
    url: String?,
    parent: Int?,
    children: [AlgoliaItem]?
  ) {
    self.id = id
    self.type = type
    self.title = title
    self.text = text
    self.points = points
    self.author = author
    self.time = time
    self.url = url
    self.parent = parent
    self.children = children
  }

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case type = "type"
    case title = "title"
    case text = "text"
    case points = "points"
    case author = "author"
    case time = "created_at_i"
    case url = "url"
    case parent = "parent_id"
    case children = "children"
  }
}
