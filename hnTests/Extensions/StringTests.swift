@testable import hn
import Quick
import Nimble

class StringExtensionSpec: QuickSpec {
    override func spec() {
        describe(".decodingHtmlEntities()") {
            context("when the string contains no encoded entities") {
                it("returns the original string") {
                    let original = "This is my string"
                    let encoded = original
                    let decoded = encoded.decodingHtmlEntities()
                    expect(decoded).to(equal(original))
                }
            }

            context("when the string contains an encoded entity") {
                it("correctly decodes the string") {
                    let original = "There's an apostrophee in here"
                    let encoded = "There&apos;s an apostrophee in here"
                    let decoded = encoded.decodingHtmlEntities()
                    expect(decoded).to(equal(original))
                }
            }
        }
    }
}
