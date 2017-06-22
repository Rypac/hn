import Foundation

extension Sequence {
    func flatMap<U>(async perform: (Self.Iterator.Element, @escaping (U?) -> Void) -> Void, withResult: @escaping ([U]) -> Void) {
        var values = [U]()
        let requestGroup = DispatchGroup()
        forEach { value in
            requestGroup.enter()
            perform(value) { asyncValue in
                asyncValue.map { values.append($0) }
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            withResult(values)
        }
    }

    func flatMap<U>(async perform: (Self.Iterator.Element, @escaping ([U]) -> Void) -> Void, withResult: @escaping ([U]) -> Void) {
        var values = [U]()
        let requestGroup = DispatchGroup()
        forEach { value in
            requestGroup.enter()
            perform(value) { asyncValue in
                values += asyncValue
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            withResult(values)
        }
    }
}
