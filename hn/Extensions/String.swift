import Foundation

extension String {
  func nsRange(from range: Range<Index>) -> NSRange {
    let stringView = utf16
    let lower = range.lowerBound.samePosition(in: stringView)
    let upper = range.upperBound.samePosition(in: stringView)
    return NSRange(
      location: stringView.distance(from: stringView.startIndex, to: lower),
      length: stringView.distance(from: lower, to: upper)
    )
  }

  func slice(from: String, to: String) -> String? {
    return range(of: from).flatMap { start in
      range(of: to, range: start.upperBound ..< endIndex).flatMap { end in
        substring(with: start.upperBound ..< end.lowerBound)
      }
    }
  }
}
