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
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("What is this?"))
                }

                it("returns no formatting points") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(beEmpty())
                }
            }

            context("when the string contains a <p> tag") {
                let original = "This is a string.<p>This is another string."

                it("returns a string without the <p> tag") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This is a string.\n\nThis is another string."))
                }

                it("returns a paragraph formatting element applied to the appropriate range") {
                    let (_, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }
                    let tag = original.range(of: "<p>")!
                    let upper = original.index(tag.lowerBound, offsetBy: 2)
                    let formatRange = tag.lowerBound..<upper

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.paragraph))
                    expect(range.lowerBound).to(equal(tag.lowerBound))
                    expect(range).to(equal(formatRange))
                }
            }

            context("when the string contains a pair of <i> tags") {
                let original = "This is an <i>interesting</i> string."

                it("returns a string without the <i> tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This is an interesting string."))
                }

                it("returns an italic formatting element applied to the appropriate range") {
                    let (result, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.italic))
                    expect(range).to(equal(result.range(of: "interesting")))
                }
            }

            context("when the string contains a pair of <b> tags") {
                let original = "This is an interesting <b>string</b>."

                it("returns a string without the <b> tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This is an interesting string."))
                }

                it("returns a bold formatting element applied to the appropriate range") {
                    let (result, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.bold))
                    expect(range).to(equal(result.range(of: "string")))
                }
            }

            context("when the string contains a pair of <a> tags") {
                let original = "I find <a href=\"https://www.google.com\">this search engine</a> to be helpful."

                it("returns a string without the <a> tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("I find this search engine to be helpful."))
                }

                it("returns a url formatting element applied to the appropriate range") {
                    let (result, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.url))
                    expect(range).to(equal(result.range(of: "this search engine")))
                }
            }

            context("when the string contains a pair of <pre> tags") {
                let original = "This is <pre>  really critical  </pre> stuff."

                it("returns a string without the <pre> tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This is   really critical   stuff."))
                }

                it("returns a preformatted formatting element applied to the appropriate range") {
                    let (result, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.preformatted))
                    expect(range).to(equal(result.range(of: "  really critical  ")))
                }
            }

            context("when the string contains a pair of <code> tags") {
                let original = "I like to use the <code>++</code> operator."

                it("returns a string without the <code> tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("I like to use the ++ operator."))
                }

                it("returns a preformatted formatting element applied to the appropriate range") {
                    let (result, formatting) = original.strippingHtmlElements()
                    guard let (type, range) = formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(formatting).to(haveCount(1))
                    expect(type).to(equal(FormattingOption.code))
                    expect(range).to(equal(result.range(of: "++")))
                }
            }

            context("when the string contains an unbalanced tag") {
                let original = "This is an <i>interesting string."

                it("returns a string without the tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This is an interesting string."))
                }

                it("returns no formatting points") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(beEmpty())
                }
            }

            context("when the string contains a mixture of tags") {
                let original = "This<p><b>is</b> <b>a</b> string.<i>This</i> is<p>another <i>string</i>."

                it("returns a string without the tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This\n\nis a string.This is\n\nanother string."))
                }

                it("returns all of the formatting elements") {
                    let (_, formatting) = original.strippingHtmlElements()
                    expect(formatting).to(haveCount(6))
                }
            }

            context("when the string contains overlapping tags") {
                let original = "This <i>string <b>is</b> really</i> cool."

                it("returns a string without the tags") {
                    let (result, _) = original.strippingHtmlElements()
                    expect(result).to(equal("This string is really cool."))
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
