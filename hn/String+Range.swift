import Foundation

extension String {
  func slice(from: String, to: String) -> String? {
    return range(of: from).flatMap { start in
      range(of: to, range: start.upperBound ..< endIndex).flatMap { end in
        String(self[start.upperBound ..< end.lowerBound])
      }
    }
  }
}
