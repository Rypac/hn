@testable import hn
import XCTest

class URLTest: XCTest {
  func test_prettyHost_returnsOnlyTheHostWhenTheUrlContainsNoDomain() {
    let url = URL(string: "https://example.com")

    XCTAssertEqual(url?.prettyHost, "example.com")
  }

  func test_prettyHost_returnsOnlyTheHostAndSubdomainWhenTheUrlContainsANonWWWDomain() {
    let url = URL(string: "https://this.example.io")

    XCTAssertEqual(url?.prettyHost, "this.example.io")
  }

  func test_prettyHost_returnsOnlyTheHostWhenTheUrlContainsAWWWDomain() {
    let url = URL(string: "https://www.example.com.au")

    XCTAssertEqual(url?.prettyHost, "example.com.au")
  }

  func test_prettyHost_returnsOnlyTheHostWhenTheUrlContainsAdditionalPathComponents() {
    let url = URL(string: "http://example.org/stuff/here")

    XCTAssertEqual(url?.prettyHost, "example.org")
  }
}
