@testable import hn
import Nimble
import Quick

class ItemSpec: QuickSpec {
  override func spec() {
    describe(".extractPostAndComments") {
      context("for a story with no comments") {
        let item = Item.fake(.story, id: 123, kids: [])

        it("returns the post") {
          let post = item.extractPostAndComments()?.0
          expect(post?.id).to(equal(123))
        }

        it("returns no comments") {
          let comments = item.extractPostAndComments()?.1
          expect(comments).to(beEmpty())
        }
      }

      context("for a story with only top level comments") {
        let item = Item.fake(.story, id: 123, kids: [
          Item.fake(.comment, id: 111, kids: []),
          Item.fake(.comment, id: 222, kids: []),
          Item.fake(.comment, id: 333, kids: []),
        ])

        it("returns the post") {
          let post = item.extractPostAndComments()?.0
          expect(post?.id).to(equal(123))
        }

        it("returns the comments in order") {
          let comments = item.extractPostAndComments()?.1
          expect(comments).to(haveCount(3))
          expect(comments?[0].id).to(equal(111))
          expect(comments?[1].id).to(equal(222))
          expect(comments?[2].id).to(equal(333))
        }
      }

      context("for a story with a complex nesting of comments") {
        let item = Item.fake(.story, id: 123, kids: [
          Item.fake(.comment, id: 111, kids: [
            Item.fake(.comment, id: 555, kids: [
              Item.fake(.comment, id: 777, kids: []),
            ]),
            Item.fake(.comment, id: 666, kids: []),
          ]),
          Item.fake(.comment, id: 222, kids: []),
          Item.fake(.comment, id: 333, kids: [
            Item.fake(.comment, id: 444, kids: [
              Item.fake(.comment, id: 888, kids: [
                Item.fake(.comment, id: 000, kids: []),
                Item.fake(.comment, id: 999, kids: []),
              ]),
            ]),
          ]),
        ])

        it("returns the post") {
          let post = item.extractPostAndComments()?.0
          expect(post?.id).to(equal(123))
        }

        it("returns the comments in order unwrapping children") {
          let comments = item.extractPostAndComments()?.1
          expect(comments).to(haveCount(10))
          expect(comments?[0].id).to(equal(111))
          expect(comments?[1].id).to(equal(555))
          expect(comments?[2].id).to(equal(777))
          expect(comments?[3].id).to(equal(666))
          expect(comments?[4].id).to(equal(222))
          expect(comments?[5].id).to(equal(333))
          expect(comments?[6].id).to(equal(444))
          expect(comments?[7].id).to(equal(888))
          expect(comments?[8].id).to(equal(000))
          expect(comments?[9].id).to(equal(999))
        }
      }
    }
  }
}
