@testable import hn
import XCTest

class StringHtmlParsingTests: XCTest {
  func test_strippingHtmlElements_whenTheStringContainsNoHtml_returnsAnIdenticalStringWithNoFormattingPoints() {
    let original = "This is a string which contains no HTML elements"

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, original)
    XCTAssertTrue(result.formatting.isEmpty)
  }

  func test_strippingHtmlElements_whenTheStringContainsAnUnknownTag_returnsAStringWithoutTheUnknownTagAndNoFormattingPoints() {
    let original = "What is <w>this?"

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "What is this?")
    XCTAssertTrue(result.formatting.isEmpty)
  }

  func test_strippingHtmlElements_whenTheStringContainsAnUnbalancedPTag_returnsAStringWithoutTheTagAndFormattingInTheAppropriateRange() {
    let original = "This is a string.<p>This is another string."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is a string.\n\nThis is another string.")
    XCTAssertEqual(result.formatting.count, 2)
    XCTAssertEqual(result.formatting[0].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "This is a string."))
    XCTAssertEqual(result.formatting[1].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[1].range, result.text.range(of: "This is another string."))
  }

  func test_strippingHtmlElements_whenTheStringIsEnclosedInPTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "<p>This is a string. This is another string.</p>"

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is a string. This is another string.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[0].range, result.text.startIndex ..< result.text.endIndex)
  }

  func test_strippingHtmlElements_whenTheStringContainsMultiplePTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "<p>This is a string.</p><p>This is another string.</p>"

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is a string.\n\nThis is another string.")
    XCTAssertEqual(result.formatting.count, 2)
    XCTAssertEqual(result.formatting[0].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "This is a string."))
    XCTAssertEqual(result.formatting[1].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[1].range, result.text.range(of: "This is another string."))
  }

  func test_strippingHtmlElements_whenTheStringContainsBTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This<br>is an interesting<br>string."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This\nis an interesting\nstring.")
    XCTAssertEqual(result.formatting.count, 2)
    XCTAssertEqual(result.formatting[0].type, Formatting.linebreak)
    XCTAssertEqual(result.formatting[1].type, Formatting.linebreak)
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfITags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This is an <i>interesting</i> string."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is an interesting string.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.italic)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "interesting"))
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfBTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This is an interesting <b>string</b>."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is an interesting string.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.bold)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "string"))
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfUTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This is an <u>interesting</u> string."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is an interesting string.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.underline)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "interesting"))
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfATags_withNoEmbeddedHref_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "I find <a>this search engine</a> to be helpful."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "I find this search engine to be helpful.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.url)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "this search engine"))
    XCTAssertNil(result.formatting[0].attributes.find("href"))
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfATags_withAnEmbeddedHref_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "I find <a href=\"https://www.google.com\">this search engine</a> to be helpful."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "I find this search engine to be helpful.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.url)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "this search engine"))
    XCTAssertEqual(result.formatting[0].attributes.find("href"), "https://www.google.com")
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfPreTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This is <pre>  really critical  </pre> stuff."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is   really critical   stuff.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.preformatted)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "  really critical  "))
  }

  func test_strippingHtmlElements_whenTheStringContainsAPairOfCodeTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "I like to use the <code>++</code> operator."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "I like to use the ++ operator.")
    XCTAssertEqual(result.formatting.count, 1)
    XCTAssertEqual(result.formatting[0].type, Formatting.code)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "++"))
  }

  func test_strippingHtmlElements_whenTheStringContainsAnUnbalancedTag_returnsAStringWithoutTheTagAndFormattingInTheAppropriateRange() {
    let original = "This is an <i>interesting string."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This is an interesting string.")
    XCTAssertTrue(result.formatting.isEmpty)
  }

  func test_strippingHtmlElements_whenTheStringContainsAMixtureOfTags_returnsAStringWithoutTheTagsAndFormattingInTheAppropriateRange() {
    let original = "This<p><b>contains</b> <b>some</b> strings.<i>Also</i> is<p><i>another string</i>."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This\n\ncontains some strings.Also is\n\nanother string.")
    XCTAssertEqual(result.formatting.count, 7)
    XCTAssertEqual(result.formatting[0].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "This"))
    XCTAssertEqual(result.formatting[1].type, Formatting.bold)
    XCTAssertEqual(result.formatting[1].range, result.text.range(of: "contains"))
    XCTAssertEqual(result.formatting[2].type, Formatting.bold)
    XCTAssertEqual(result.formatting[2].range, result.text.range(of: "some"))
    XCTAssertEqual(result.formatting[3].type, Formatting.italic)
    XCTAssertEqual(result.formatting[3].range, result.text.range(of: "Also"))
    XCTAssertEqual(result.formatting[4].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[4].range, result.text.range(of: "contains some strings.Also is"))
    XCTAssertEqual(result.formatting[5].type, Formatting.italic)
    XCTAssertEqual(result.formatting[5].range, result.text.range(of: "another string"))
    XCTAssertEqual(result.formatting[6].type, Formatting.paragraph)
    XCTAssertEqual(result.formatting[6].range, result.text.range(of: "another string."))
  }

  func test_strippingHtmlElements_whenTheStringContainsOverlappingTags_returnsAStringWithoutTheTagAndFormattingInTheAppropriateRange() {
    let original = "This <i>string <b>has</b> to be really</i> cool."

    let result = original.strippingHtmlElements()

    XCTAssertEqual(result.text, "This string has to be really cool.")
    XCTAssertEqual(result.formatting.count, 2)
    XCTAssertEqual(result.formatting[0].type, Formatting.bold)
    XCTAssertEqual(result.formatting[0].range, result.text.range(of: "has"))
    XCTAssertEqual(result.formatting[1].type, Formatting.italic)
    XCTAssertEqual(result.formatting[1].range, result.text.range(of: "string has to be"))
  }

  func test_strippingHtmlElements_whenTheStringContainsHtmlEncodedEntities_correctlyDecodesTheString() {
    let encodedDecoded = [
      ("&quot;", "\""),
      ("&apos;", "'"),
      ("&amp;", "&"),
      ("&lt;", "<"),
      ("&gt;", ">"),
      ("&#x2F;", "/"),
      ("&#X2F;", "/"),
      ("&#47;", "/"),
    ]

    for (encoded, decoded) in encodedDecoded {
      let originalExpected = [
        ("There\(encoded)s an encoded entity in here", "There\(decoded)s an encoded entity in here"),
        ("There\(encoded)s more than one \(encoded) in here", "There\(decoded)s more than one \(decoded) in here"),
        ("I have double\(encoded)\(encoded) in here", "I have double\(decoded)\(decoded) in here"),
        ("\(encoded)Begins with an encoded entity", "\(decoded)Begins with an encoded entity"),
        ("I end with a\(encoded)", "I end with a\(decoded)"),
        ("\(encoded)", "\(decoded)"),
      ]

      for (original, expected) in originalExpected {
        let result = original.strippingHtmlElements()

        XCTAssertEqual(result.text, expected)
      }
    }
  }
}
