import Foundation

extension Array {
    var sliced: ArraySlice<Element> {
        return self[indices]
    }
}
