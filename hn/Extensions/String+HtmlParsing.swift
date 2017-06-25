import Foundation

enum FormattingOption {
    case paragraph
    case url
    case itallic
    case bold
    case code
}

extension String {
    typealias FormattingPoints = [(FormattingOption, Range<Index>)]

    private func parseTag(_ index: Range<Index>) -> (Range<Index>, Range<Index>)? {
        return range(from: "<", to: ">", indexRange: index.lowerBound..<index.upperBound)
    }

    func strippingHtmlElements() -> (String, FormattingPoints) {
        var result = ""
        var points = [(FormattingOption, Range<Index>)]()
        var position = startIndex

        parser: while let (start, end) = parseTag(position..<endIndex) {
            let parsed = self[start.upperBound..<end.lowerBound]
            switch parsed {
            case "p":
                let replacement = "\n\n"
                let replacementEnd = index(start.lowerBound, offsetBy: replacement.characters.count)
                result.append(self[position..<start.lowerBound])
                result.append(replacement)
                points.append((.paragraph, start.lowerBound..<replacementEnd))
                position = end.upperBound
            case "i":
                guard let (closingStart, closingEnd) = parseTag(end.upperBound..<endIndex) else {
                    break parser
                }

                let enclosed = self[end.upperBound..<closingStart.lowerBound]
                let enclosedEnd = index(start.lowerBound, offsetBy: enclosed.characters.count)
                result.append(self[position..<start.lowerBound])
                result.append(enclosed)
                points.append((.itallic, start.lowerBound..<enclosedEnd))
                position = closingEnd.upperBound
            case "b":
                guard let (closingStart, closingEnd) = parseTag(end.upperBound..<endIndex) else {
                    break parser
                }

                let enclosed = self[end.upperBound..<closingStart.lowerBound]
                let enclosedEnd = index(start.lowerBound, offsetBy: enclosed.characters.count)
                result.append(self[position..<start.lowerBound])
                result.append(enclosed)
                points.append((.bold, start.lowerBound..<enclosedEnd))
                position = closingEnd.upperBound
            default:
                result.append(self[position..<end.upperBound])
                position = end.upperBound
            }
        }

        result.append(self[position..<endIndex])
        return (result, points)
    }
}
