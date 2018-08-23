@testable import hn
import Nimble
import Quick

class URLSpec: QuickSpec {
  override func spec() {
    describe(".prettyHost") {
      it("returns only the host when the url contains no subdomain") {
        let url = URL(string: "https://example.com")
        expect(url?.prettyHost).to(equal("example.com"))
      }

      it("returns only the host and subdomain when the url contains a non www subdomain") {
        let url = URL(string: "https://this.example.io")
        expect(url?.prettyHost).to(equal("this.example.io"))
      }

      it("returns only the host when the url contains a www subdomain") {
        let url = URL(string: "https://www.example.com.au")
        expect(url?.prettyHost).to(equal("example.com.au"))
      }

      it("returns only the host when the url contains additional path components") {
        let url = URL(string: "http://example.org/stuff/here")
        expect(url?.prettyHost).to(equal("example.org"))
      }
    }
  }
}
