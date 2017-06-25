import Foundation

extension String {
    func range(from: String, to: String) -> (Range<Index>, Range<Index>)? {
        return range(from: from, to: to, indexRange: startIndex..<endIndex)
    }

    func range(from: String, to: String, indexRange: Range<Index>) -> (Range<Index>, Range<Index>)? {
        guard
            let start = range(of: from, range: indexRange.lowerBound..<indexRange.upperBound),
            let end = range(of: to, range: start.lowerBound..<indexRange.upperBound)
        else {
            return .none
        }
        return (start, end)
    }
}

private let entityEncodings: [String: Character] = [
    "quot" : "\"",
    "amp"  : "&",
    "apos" : "'",
    "lt"   : "<",
    "gt"   : ">"
]

extension String {
    func decodingHtmlEntities() -> String {
        var result = ""
        var position = startIndex

        while let (start, end) = range(from: "&", to: ";", indexRange: position..<endIndex) {
            let encoded = self[start.upperBound..<end.lowerBound]
            if let decoded = encoded.decode() {
                result.append(self[position..<start.lowerBound])
                result.append(decoded)
            } else {
                result.append(self[position..<end.upperBound])
            }
            position = end.upperBound
        }

        result.append(self[position..<endIndex])
        return result
    }

    private func decode() -> Character? {
        guard hasPrefix("#") else {
            return entityEncodings[self]
        }

        let offset = index(after: startIndex)
        let encoded = self[offset..<endIndex]
        return encoded.hasPrefix("x") || encoded.hasPrefix("X")
            ? encoded[index(after: encoded.startIndex)..<encoded.endIndex].decode(base: 16)
            : encoded.decode(base: 10)
    }

    private func decode(base: Int) -> Character? {
        guard
            let code = UInt32(self, radix: base),
            let unicode = UnicodeScalar(code)
        else {
            return .none
        }
        return Character(unicode)
    }
}
