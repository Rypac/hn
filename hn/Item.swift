import Foundation

struct Item: Decodable {
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

  let id: Int
  let type: PostType
  let title: String?
  let text: String?
  let score: Int?
  let author: String?
  let time: Int?
  let url: String?
  let parent: Int?
  let descendants: Int?
  let parts: [Int]?
  let kids: [Int]?
  let dead: Bool?
  let deleted: Bool?

  init(
    id: Int,
    type: PostType,
    title: String?,
    text: String?,
    score: Int?,
    author: String?,
    time: Int?,
    url: String?,
    parent: Int?,
    descendants: Int?,
    kids: [Int]?,
    parts: [Int]?,
    dead: Bool,
    deleted: Bool
  ) {
    self.id = id
    self.type = type
    self.title = title
    self.text = text
    self.score = score
    self.author = author
    self.time = time
    self.url = url
    self.parent = parent
    self.descendants = descendants
    self.kids = kids
    self.parts = parts
    self.dead = dead
    self.deleted = deleted
  }

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case type = "type"
    case title = "title"
    case text = "text"
    case score = "points"
    case author = "author"
    case time = "created_at_i"
    case url = "url"
    case parent = "parent"
    case descendants = "descendants"
    case kids = "kids"
    case parts = "parts"
    case deleted = "deleted"
    case dead = "dead"
  }
}
