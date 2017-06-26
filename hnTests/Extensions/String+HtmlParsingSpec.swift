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

                it("returns a string without the unknown tag") {
                    let stripped = "What is this?"
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
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
                    let tag = original.range(of: "<p>")!
                    let upper = original.index(tag.lowerBound, offsetBy: 2)
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
                    expect(type).to(equal(FormattingOption.italic))
                }

                it("applies the formatting to the region enclosed by the <i> tags") {
                    let (_, formatting) = original.strippingHtmlElements()
                    let (_, range) = formatting.first!
                    let tag = original.range(of: "<i>")!
                    let upper = original.index(tag.lowerBound, offsetBy: 11)
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
                    let tag = original.range(of: "<b>")!
                    let upper = original.index(tag.lowerBound, offsetBy: 6)
                    let formatRange = tag.lowerBound..<upper

                    expect(range.lowerBound).to(equal(tag.lowerBound))
                    expect(range).to(equal(formatRange))
                }
            }

            context("when the string contains an unbalanced tag") {
                let original = "This is an <i>interesting string."

                it("returns a string without the tags") {
                    let original = "This is an interesting string."
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

            context("when the string contains overlapping tags") {
                let original = "This <i>string <b>is</b> really</i> cool."

                it("returns a string without the tags") {
                    let stripped = "This string is really cool."
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal(stripped))
                }

                it("returns all of the formatting elements") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(2))
                }
            }

            context("when the string contains html encoded entities") {
                itBehavesLike("a html encoded entity") {[ "e": "&quot;", "d": "\"" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&apos;", "d": "'" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&amp;",  "d": "&" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&lt;",   "d": "<" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&gt;",   "d": ">" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&#x2F;", "d": "/" ]}

                itBehavesLike("a html encoded entity") {[ "e": "&#X2F;", "d": "/" ]}
                
                itBehavesLike("a html encoded entity") {[ "e": "&#47;",  "d": "/" ]}
            }
        }
    }
}

class StringHtmlParsingConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a html encoded string") { (context: @escaping SharedExampleContext) in
            it("correctly decodes the string") {
                let encoded = context()["encoded"] as! String
                let decoded = context()["decoded"] as! String
                let (result, _) = encoded.strippingHtmlElements()
                expect(result).to(equal(decoded))
            }
        }

        sharedExamples("a html encoded entity") { (context: @escaping SharedExampleContext) in
            let encoded = context()["e"] as! String
            let decoded = context()["d"] as! String

            describe("when the string contains a single encoded entity") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "There\(encoded)s an encoded entity in here",
                    "decoded": "There\(decoded)s an encoded entity in here"
                ]}
            }

            describe("when the string contains multiple separated encoded entities") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "There\(encoded)s more than one \(encoded) in here",
                    "decoded": "There\(decoded)s more than one \(decoded) in here"
                ]}
            }

            describe("when the string contains multiple successive encoded entities") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "I have double\(encoded)\(encoded) in here",
                    "decoded": "I have double\(decoded)\(decoded) in here"
                ]}
            }

            describe("when the string begins with an encoded entity") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "\(encoded)Begins with an encoded entity",
                    "decoded": "\(decoded)Begins with an encoded entity"
                ]}
            }

            describe("when the string ends with an encoded entity") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "I end with a\(encoded)",
                    "decoded": "I end with a\(decoded)"
                ]}
            }

            describe("when the string is only a entity") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "\(encoded)",
                    "decoded": "\(decoded)"
                ]}
            }
        }
    }
}
