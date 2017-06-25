@testable import hn
import Quick
import Nimble

class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe(".decodingHtmlEntities()") {
            context("when the string contains no encoded entities") {
                itBehavesLike("a html encoded string") {[
                    "encoded": "There is no encoding here",
                    "decoded": "There is no encoding here"
                ]}
            }

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

class StringExtensionConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a html encoded string") { (context: @escaping SharedExampleContext) in
            it("correctly decodes the string") {
                let encoded = context()["encoded"] as! String
                let decoded = context()["decoded"] as! String
                let result = encoded.decodingHtmlEntities()
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
