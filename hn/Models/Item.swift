import Foundation

typealias Id = Int
typealias UnixTimestamp = Int

protocol ItemInitialisable {
    init?(fromItem item: Item)
}

enum Reference<T> {
    case id(Int)
    case value(T)
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
