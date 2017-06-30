@testable import hn
import Quick
import Nimble
import PromiseKit

class ItemDetailsActionSpec: QuickSpec {
    override func spec() {
        describe("fetchSiblingsForId(with:)") {
            it("calls the request with the Item endpoint for the given id") {
                let request = { id in
                    Promise(value: Item(withId: id, kids: []))
                }

                let promise = fetchSiblingsForId(with: request)(1234)
                expect(promise.value?.id).toEventually(equal(1234))
            }

            context("when the given request succeeds") {
                context("and the item contains no children") {
                    let item = Item(withId: 222, kids: [])
                    let request = { id in
                        id == 222 ? Promise(value: item) : Promise(error: "Should never be called")
                    }

                    it("resolves with only the requested item") {
                        let promise = fetchSiblingsForId(with: request)(222)
                        expect(promise.isFulfilled).toEventually(beTrue())

                        expect(promise.value?.kids).toEventually(beEmpty())
                    }
                }
            }

            context("when the given request succeeds") {
                context("and the item contains one child") {
                    let item = Item(withId: 55555, kids: [.id(77777)])
                    let child = Item(withId: 77777, kids: [])
                    let request = { (id: Int) -> Promise<Item> in
                        switch id {
                        case 55555: return Promise(value: item)
                        case 77777: return Promise(value: child)
                        default: return Promise(error: "Should never be called")
                        }
                    }

                    it("eventually resolves with the requested item and single child") {
                        let promise = fetchSiblingsForId(with: request)(55555)
                        expect(promise.isFulfilled).toEventually(beTrue())

                        let result = promise.value
                        expect(result?.id).to(equal(item.id))
                        expect(result?.kids).to(haveCount(1))
                        expect(result?.kids.first?.id).to(equal(child.id))
                    }
                }
            }

            context("when the given request fails") {
                let error = "Unable to complete the request"
                let request = { (_: Int) -> Promise<Item> in
                    Promise(error: error)
                }

                it("calls the callback with an empty array of siblings") {
                    let promise = fetchSiblingsForId(with: request)(55555)
                    expect(promise.isRejected).toEventually(beTrue())

                    expect(promise.error?.localizedDescription).to(equal(.some(error)))
                    expect(promise.value).to(beNil())
                }
            }
        }
    }
}
