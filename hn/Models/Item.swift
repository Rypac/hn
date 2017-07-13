import Foundation

typealias Id = Int
typealias UnixTimestamp = Int

protocol ItemInitialisable {
    init?(fromItem item: Item)
}

struct Item {
    enum PostType {
        case story, comment, job, poll, pollOption
    }

    let id: Id
    let type: PostType
    let title: String?
    let text: String?
    let score: Int?
    let author: String?
    let time: UnixTimestamp?
    let url: String?
    let parent: Int?
    let descendants: Int?
    internal(set) var kids: [Reference<Item>]
    let parts: [Int]?
    let dead: Bool
    let deleted: Bool

    func with(kids: [Item]) -> Item {
        var copy = self
        copy.kids = kids.map(Reference.value)
        return copy
    }
}

enum Reference<T> {
    case id(Int)
    case value(T)
}

extension Reference {
    func bindValue<U>(_ transform: (T) -> U?) -> U? {
        switch self {
        case .id: return .none
        case .value(let val): return transform(val)
        }
    }

    func bindId<U>(_ transform: (Int) -> U?) -> U? {
        switch self {
        case .id(let id): return transform(id)
        case .value: return .none
        }
    }
}

extension Reference where T == Item {
    var id: Id {
        switch self {
        case .id(let id): return id
        case .value(let item): return item.id
        }
    }
}

extension Item {
    func extractPostAndComments() -> (Post, [Comment])? {
        return flatten().map { post, comments in
            (post, comments.concurrentMap { Comment(fromItem: $0, depth: $1) }.flatMap { $0 })
        }
    }

    func flatten() -> (Post, [(Item, Int)])? {
        func flattenResponses(_ kid: Reference<Item>, depth: Int) -> [(Item, Int)] {
            return kid.bindValue { item in
                [(item, depth)] + item.kids.flatMap { flattenResponses($0, depth: depth + 1) }
            } ?? []
        }
        return Post(fromItem: self).map { ($0, kids.flatMap { flattenResponses($0, depth: 0) }) }
    }
}
