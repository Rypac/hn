@testable import hn
import Quick
import Nimble

class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe(".decodingHtmlEntities()") {
            context("when the string contains no encoded entities") {
                itBehavesLike("html encoded string") {[
                    "encoded": "There is no encoding here",
                    "decoded": "There is no encoding here"
                ]}
            }

            context("when the string contains a single encoded entity") {
                itBehavesLike("html encoded string") {[
                    "encoded": "There&apos;s an apostrophee in here",
                    "decoded": "There's an apostrophee in here"
                ]}
            }

            context("when the string contains multiple encoded entities") {
                itBehavesLike("html encoded string") {[
                    "encoded": "There&apos;s more than one &apos; in here",
                    "decoded": "There's more than one ' in here"
                ]}
            }

            context("when the string begins with an encoded entity") {
                itBehavesLike("html encoded string") {[
                    "encoded": "&apos;Twas a fine evening",
                    "decoded": "'Twas a fine evening"
                ]}
            }

            context("when the string ends with an encoded entity") {
                itBehavesLike("html encoded string") {[
                    "encoded": "I end with a&apos;",
                    "decoded": "I end with a'"
                ]}
            }
        }
    }
}

class StringExtensionConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("html encoded string") { (context: @escaping SharedExampleContext) in
            it("correctly decodes the string") {
                let encoded = context()["encoded"] as! String
                let decoded = context()["decoded"] as! String
                let result = encoded.decodingHtmlEntities()
                expect(result).to(equal(decoded))
            }
        }
    }
}
