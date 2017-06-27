@testable import hn
import Quick
import Nimble
import Alamofire

class ItemDetailsActionSpec: QuickSpec {
    override func spec() {
        describe("fetchSiblingsForId(with:)") {
            it("calls the request with the Item endpoint for the given id") {
                var endpoint: URL?
                let request = { (id: URLConvertible, onCompletion: @escaping (Result<Item>) -> Void) in
                    endpoint = try! id.asURL()
                }

                fetchSiblingsForId(with: request)(1234, { _ in })

                expect(endpoint).to(equal(try! Endpoint.item(1234).asURL()))
            }

            context("when the given request succeeds") {
                context("and the item contains no children") {
                    let item = Item(withId: 222, kids: .none)
                    let request = { (id: URLConvertible, onCompletion: @escaping (Result<Item>) -> Void) in
                        let url = try! id.asURL().absoluteString
                        if url.contains("222") {
                            onCompletion(.success(item))
                        } else {
                            fail("Should never be called")
                        }
                    }

                    it("asynchronously calls the callback with an array containing only the fetched item") {
                        var siblings = [Item]()
                        fetchSiblingsForId(with: request)(222, { items in
                            siblings = items
                        })

                        expect(siblings).toEventually(haveCount(1))
                        expect(siblings.first?.id).toEventually(equal(item.id))
                    }

                    it("asynchronously calls the callback once") {
                        var callCount = 0
                        fetchSiblingsForId(with: request)(222, { _ in
                            callCount += 1
                        })

                        expect(callCount).toEventually(equal(1))
                    }
                }
            }

            context("when the given request succeeds") {
                context("and the item contains one child") {
                    let item = Item(withId: 55555, kids: [77777])
                    let child = Item(withId: 77777, kids: .none)
                    let request = { (id: URLConvertible, onCompletion: @escaping (Result<Item>) -> Void) in
                        let url = try! id.asURL().absoluteString
                        if url.contains("55555") {
                            onCompletion(.success(item))
                        } else if url.contains("77777") {
                            onCompletion(.success(child))
                        } else {
                            fail("Should never be called")
                        }
                    }

                    it("asynchronously calls the callback with an array of the fetched item and child") {
                        var siblings = [Item]()
                        fetchSiblingsForId(with: request)(55555, { items in
                            siblings = items
                        })

                        expect(siblings).toEventually(haveCount(2))
                        expect(siblings[0].id).toEventually(equal(item.id))
                        expect(siblings[1].id).toEventually(equal(child.id))
                    }

                    it("asynchronously calls the callback one") {
                        var callCount = 0
                        fetchSiblingsForId(with: request)(55555, { _ in
                            callCount += 1
                        })

                        expect(callCount).toEventually(equal(1))
                    }
                }
            }

            context("when the given request fails") {
                let request = { (id: URLConvertible, onCompletion: @escaping (Result<Item>) -> Void) in
                    onCompletion(.failure("It failed"))
                }

                it("calls the callback with an empty array of siblings") {
                    var siblings = [Item]()
                    fetchSiblingsForId(with: request)(1234, { items in
                        siblings = items
                    })

                    expect(siblings).to(beEmpty())
                }

                it("calls the callback once") {
                    var callCount = 0
                    fetchSiblingsForId(with: request)(1234, { _ in
                        callCount += 1
                    })

                    expect(callCount).to(equal(1))
                }
            }
        }
    }
}
