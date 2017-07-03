import Foundation

struct Item {
    let id: Int
    let title: String?
    let text: String?
    let score: Int?
    let author: String?
    let time: Int?
    let type: String?
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

enum Reference<T> where T: Equatable {
    case id(Int)
    case value(T)
}

extension Item: Equatable {
    static func == (_ lhs: Item, _ rhs: Item) -> Bool {
        return lhs.id == rhs.id &&
            lhs.deleted == rhs.deleted &&
            lhs.dead == rhs.dead &&
            lhs.title == rhs.title &&
            lhs.text == rhs.text &&
            lhs.descendants == rhs.descendants &&
            lhs.parent == rhs.parent &&
            lhs.kids == rhs.kids
    }
}

extension Reference: Equatable {
    static func == (_ lhs: Reference, _ rhs: Reference) -> Bool {
        switch (lhs, rhs) {
        case let (.id(lhs), .id(rhs)):
            return lhs == rhs
        case let (.value(lhs), .value(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Item {
    func flatten() -> [Comment] {
        return flatten(depth: 0)
    }

    func flattenComments() -> [Comment] {
        return comments.flatMap { $0.flatten(depth: 0) }
    }

    private func flatten(depth: Int) -> [Comment] {
        return [Comment(item: self, depth: depth)] + comments.flatMap { $0.flatten(depth: depth + 1) }
    }

    private var comments: [Item] {
        return kids.flatMap {
            switch $0 {
            case .value(let item): return item
            case .id: return .none
            }
        }
    }
}
