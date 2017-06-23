import Foundation

extension Sequence {
    func map<U>(async perform: (Self.Iterator.Element, @escaping (U) -> Void) -> Void, withResult: @escaping ([U]) -> Void) {
        var values = [(Int, U)]()
        let requestGroup = DispatchGroup()
        enumerated().forEach { index, value in
            requestGroup.enter()
            perform(value) { asyncValue in
                values.append((index, asyncValue))
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            withResult(values.sorted(by: { $0.0 < $1.0 }).map { $0.1 })
        }
    }

    func flatMap<U>(async perform: (Self.Iterator.Element, @escaping (U?) -> Void) -> Void, withResult: @escaping ([U]) -> Void) {
        var values = [(Int, U?)]()
        let requestGroup = DispatchGroup()
        enumerated().forEach { index, value in
            requestGroup.enter()
            perform(value) { asyncValue in
                values.append((index, asyncValue))
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            withResult(values.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 })
        }
    }

    func flatMap<U>(async perform: (Self.Iterator.Element, @escaping ([U]) -> Void) -> Void, withResult: @escaping ([U]) -> Void) {
        var values = [(Int, [U])]()
        let requestGroup = DispatchGroup()
        enumerated().forEach { index, value in
            requestGroup.enter()
            perform(value) { asyncValue in
                values.append((index, asyncValue))
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            withResult(values.sorted(by: { $0.0 < $1.0 }).flatMap { $0.1 })
        }
    }
}
