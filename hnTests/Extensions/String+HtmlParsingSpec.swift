@testable import hn
import Quick
import Nimble

class StringHtmlParsingSpec: QuickSpec {
    override func spec() {
        describe(".strippingHtmlElements()") {
            context("when the string contains no HTML") {
                let original = "This is a string which contains no HTML elements"

                it("returns an identical string") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal(original))
                }

                it("returns no formatting points") {
                    let result = original.strippingHtmlElements()
                    expect(result.formatting).to(beEmpty())
                }
            }

            context("when the string contains an unknown tag") {
                let original = "What is <w>this?"

                it("returns a string without the unknown tag") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("What is this?"))
                }

                it("returns no formatting points") {
                    let result = original.strippingHtmlElements()
                    expect(result.formatting).to(beEmpty())
                }
            }

            context("when the string contains an unbalanced <p> tag") {
                let original = "This is a string.<p>This is another string."

                it("returns a string without the <p> tag") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is a string.\n\nThis is another string."))
                }

                it("returns paragraph formatting elements applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard result.formatting.count > 1 else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(2))
                    expect(result.formatting[0].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[0].range).to(equal(result.text.range(of: "This is a string.")))
                    expect(result.formatting[1].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[1].range).to(equal(result.text.range(of: "This is another string.")))
                }
            }

            context("when the string is enclosed in <p> tags") {
                let original = "<p>This is a string. This is another string.</p>"

                it("returns a string without the <p> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is a string. This is another string."))
                }

                it("returns a paragraph formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard result.formatting.count > 0 else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(result.formatting[0].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[0].range).to(equal(result.text.startIndex..<result.text.endIndex))
                }
            }

            context("when the string contains multiple <p> tags") {
                let original = "<p>This is a string.</p><p>This is another string.</p>"

                it("returns a string without the <p> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is a string.\n\nThis is another string."))
                }

                it("returns paragraph formatting elements applied to the appropriate ranges") {
                    let result = original.strippingHtmlElements()
                    guard result.formatting.count > 1 else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(2))
                    expect(result.formatting[0].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[0].range).to(equal(result.text.range(of: "This is a string.")))
                    expect(result.formatting[1].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[1].range).to(equal(result.text.range(of: "This is another string.")))
                }
            }

            context("when the string contains <br> tags") {
                let original = "This<br>is an interesting<br>string."

                it("returns a string without the <br> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This\nis an interesting\nstring."))
                }

                it("returns linbreak formatting elements applied to the appropriate ranges") {
                    let result = original.strippingHtmlElements()

                    expect(result.formatting).to(haveCount(2))
                    expect(result.formatting[0].type).to(equal(Formatting.linebreak))
                    expect(result.formatting[1].type).to(equal(Formatting.linebreak))
                }
            }

            context("when the string contains a pair of <i> tags") {
                let original = "This is an <i>interesting</i> string."

                it("returns a string without the <i> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is an interesting string."))
                }

                it("returns an italic formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.italic))
                    expect(formatting.range).to(equal(result.text.range(of: "interesting")))
                }
            }

            context("when the string contains a pair of <b> tags") {
                let original = "This is an interesting <b>string</b>."

                it("returns a string without the <b> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is an interesting string."))
                }

                it("returns a bold formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.bold))
                    expect(formatting.range).to(equal(result.text.range(of: "string")))
                }
            }

            context("when the string contains a pair of <u> tags") {
                let original = "This is an <u>interesting</u> string."

                it("returns a string without the <u> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is an interesting string."))
                }

                it("returns an underline formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.underline))
                    expect(formatting.range).to(equal(result.text.range(of: "interesting")))
                }
            }

            context("when the string contains a pair of <a> tags with no embedded href") {
                let original = "I find <a>this search engine</a> to be helpful."

                it("returns a string without the <a> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("I find this search engine to be helpful."))
                }

                it("returns a url formatting element applied to the appropriate range and no link") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.url))
                    expect(formatting.range).to(equal(result.text.range(of: "this search engine")))
                    expect(formatting.attributes.find("href")).to(beNil())
                }
            }

            context("when the string contains a pair of <a> tags with an embedded href") {
                let original = "I find <a href=\"https://www.google.com\">this search engine</a> to be helpful."

                it("returns a string without the <a> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("I find this search engine to be helpful."))
                }

                it("returns a url formatting element applied to the appropriate range and link from the href") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.url))
                    expect(formatting.range).to(equal(result.text.range(of: "this search engine")))
                    expect(formatting.attributes.find("href")).to(equal("https://www.google.com"))
                }
            }

            context("when the string contains a pair of <pre> tags") {
                let original = "This is <pre>  really critical  </pre> stuff."

                it("returns a string without the <pre> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is   really critical   stuff."))
                }

                it("returns a preformatted formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.preformatted))
                    expect(formatting.range).to(equal(result.text.range(of: "  really critical  ")))
                }
            }

            context("when the string contains a pair of <code> tags") {
                let original = "I like to use the <code>++</code> operator."

                it("returns a string without the <code> tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("I like to use the ++ operator."))
                }

                it("returns a preformatted formatting element applied to the appropriate range") {
                    let result = original.strippingHtmlElements()
                    guard let formatting = result.formatting.first else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(1))
                    expect(formatting.type).to(equal(Formatting.code))
                    expect(formatting.range).to(equal(result.text.range(of: "++")))
                }
            }

            context("when the string contains an unbalanced tag") {
                let original = "This is an <i>interesting string."

                it("returns a string without the tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This is an interesting string."))
                }

                it("returns no formatting points") {
                    let result = original.strippingHtmlElements()
                    expect(result.formatting).to(beEmpty())
                }
            }

            context("when the string contains a mixture of tags") {
                let original = "This<p><b>contains</b> <b>some</b> strings.<i>Also</i> is<p><i>another string</i>."

                it("returns a string without the tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This\n\ncontains some strings.Also is\n\nanother string."))
                }

                it("returns all of the formatting elements") {
                    let result = original.strippingHtmlElements()

                    expect(result.formatting).to(haveCount(7))
                    expect(result.formatting[0].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[0].range).to(equal(result.text.range(of: "This")))
                    expect(result.formatting[1].type).to(equal(Formatting.bold))
                    expect(result.formatting[1].range).to(equal(result.text.range(of: "contains")))
                    expect(result.formatting[2].type).to(equal(Formatting.bold))
                    expect(result.formatting[2].range).to(equal(result.text.range(of: "some")))
                    expect(result.formatting[3].type).to(equal(Formatting.italic))
                    expect(result.formatting[3].range).to(equal(result.text.range(of: "Also")))
                    expect(result.formatting[4].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[4].range).to(equal(result.text.range(of: "contains some strings.Also is")))
                    expect(result.formatting[5].type).to(equal(Formatting.italic))
                    expect(result.formatting[5].range).to(equal(result.text.range(of: "another string")))
                    expect(result.formatting[6].type).to(equal(Formatting.paragraph))
                    expect(result.formatting[6].range).to(equal(result.text.range(of: "another string.")))
                }
            }

            context("when the string contains overlapping tags") {
                let original = "This <i>string <b>has</b> to be really</i> cool."

                it("returns a string without the tags") {
                    let result = original.strippingHtmlElements()
                    expect(result.text).to(equal("This string has to be really cool."))
                }

                it("returns all of the formatting elements") {
                    let result = original.strippingHtmlElements()
                    guard result.formatting.count > 1 else {
                        fail("Should contain formatting elements")
                        return
                    }

                    expect(result.formatting).to(haveCount(2))
                    expect(result.formatting[0].type).to(equal(Formatting.bold))
                    expect(result.formatting[0].range).to(equal(result.text.range(of: "has")))
                    expect(result.formatting[1].type).to(equal(Formatting.italic))
                    expect(result.formatting[1].range).to(equal(result.text.range(of: "string has to be really")))
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
                let result = encoded.strippingHtmlElements()
                expect(result.text).to(equal(decoded))
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
