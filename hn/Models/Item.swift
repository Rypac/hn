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

enum Reference<T> {
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
            lhs.kids.count == rhs.kids.count
    }
}
