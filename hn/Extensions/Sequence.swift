import Foundation

extension Sequence {
    func forAll<U>(async perform: (Self.Iterator.Element, @escaping ([U]) -> Void) -> Void, after: @escaping ([U]) -> Void) {
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
            after(values)
        }
    }
}
