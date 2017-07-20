import IGListKit

protocol DataProvider {}

protocol DataSource {
    associatedtype Provider

    var provider: Provider { get set }
    var diff: ListIndexPathResult? { get }
}
