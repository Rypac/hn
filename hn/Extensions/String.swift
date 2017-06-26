import Foundation

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        let stringView = utf16
        let lower = range.lowerBound.samePosition(in: stringView)
        let upper = range.upperBound.samePosition(in: stringView)
        return NSRange(
            location: stringView.distance(from: stringView.startIndex, to: lower),
            length: stringView.distance(from: lower, to: upper))
    }
}
