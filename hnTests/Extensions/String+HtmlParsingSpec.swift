@testable import hn
import Quick
import Nimble

class StringHtmlParsingSpec: QuickSpec {
    override func spec() {
        describe(".strippingHtmlElements()") {
            context("when the string contains no HTML") {
                let original = "This is a string which contains no HTML elements"

                it("returns an identical string") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(original))
                }

                it("returns no formatting points") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(beEmpty())
                }
            }

            context("when the string contains an unknown tag") {
                let original = "What is <w>this?"

                it("returns an identical string") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(original))
                }

                it("returns no formatting points") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(beEmpty())
                }
            }

            context("when the string contains a <p> tag") {
                let original = "This is a string.<p>This is another string."

                it("returns a string without the <p> tag") {
                    let stripped = "This is a string.\n\nThis is another string."
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
                }

                it("returns a single formatting element") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(1))
                }

                it("correctly parses the <p> tag formatting option") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (type, _) = formatting.first!
                    expect(type).to(equal(FormattingOption.paragraph))
                }

                it("applies the formatting to the region enclosed by the <p> tag") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (_, range) = formatting.first!
                    let tag: Range<String.Index> = original.range(of: "<p>")!
                    let upper: String.Index = original.index(tag.lowerBound, offsetBy: 2)
                    let formatRange = tag.lowerBound..<upper

                    expect(range.lowerBound).to(equal(tag.lowerBound))
                    expect(range).to(equal(formatRange))
                }
            }

            context("when the string contains a pair of <i> tags") {
                let original = "This is an <i>interesting</i> string."

                it("returns a string without the <i> tags") {
                    let stripped = "This is an interesting string."
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
                }

                it("returns a single formatting element") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(1))
                }

                it("correctly parses the <i> tag formatting option") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (type, _) = formatting.first!
                    expect(type).to(equal(FormattingOption.itallic))
                }

                it("applies the formatting to the region enclosed by the <i> tags") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (_, range) = formatting.first!
                    let tag: Range<String.Index> = original.range(of: "<i>")!
                    let upper: String.Index = original.index(tag.lowerBound, offsetBy: 11)
                    let formatRange = tag.lowerBound..<upper

                    expect(range.lowerBound).to(equal(tag.lowerBound))
                    expect(range).to(equal(formatRange))
                }
            }

            context("when the string contains a pair of <b> tags") {
                let original = "This is an interesting <b>string</b>."

                it("returns a string without the <b> tags") {
                    let stripped = "This is an interesting string."
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
                }

                it("returns a single formatting element") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(1))
                }

                it("correctly parses the <b> tag formatting option") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (type, _) = formatting.first!
                    expect(type).to(equal(FormattingOption.bold))
                }

                it("applies the formatting to the region enclosed by the <b> tags") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (_, range) = formatting.first!
                    let tag: Range<String.Index> = original.range(of: "<b>")!
                    let upper: String.Index = original.index(tag.lowerBound, offsetBy: 6)
                    let formatRange = tag.lowerBound..<upper

                    expect(range.lowerBound).to(equal(tag.lowerBound))
                    expect(range).to(equal(formatRange))
                }
            }

            context("when the string contains an unbalanced tag") {
                let original = "This is an <i>interesting string."

                it("returns an identical string") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(original))
                }

                it("returns no formatting points") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(beEmpty())
                }
            }

            context("when the string contains a mixture of tags") {
                let original = "This<p><b>is</b> <b>a</b> string.<i>This</i> is<p>another <i>string</i>."

                it("returns a string without the tags") {
                    let stripped = "This\n\nis a string.This is\n\nanother string."
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
                }

                it("returns all of the formatting elements") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(6))
                }
            }
        }
    }
}
