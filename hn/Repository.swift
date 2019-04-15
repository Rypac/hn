import Foundation
import RxSwift

class Repository {
	private let firebaseService: FirebaseService
	private let algoliaService: AlgoliaService

  init(firebaseService: FirebaseService = FirebaseService(), algoliaService: AlgoliaService = AlgoliaService()) {
    self.firebaseService = firebaseService
		self.algoliaService = algoliaService
  }

  func fetchTopStories() -> Single<[FirebaseItem]> {
		return firebaseService.topStories()
			.flatMap { [firebaseService] (items: [Int]) -> Single<[FirebaseItem]> in
        let batchedStories = items.prefix(25)
        return Observable.from(batchedStories.map(firebaseService.item(id:)))
          .merge()
          .toArray()
          .map { stories in
            stories.sorted(relativeTo: batchedStories, selector: { $0.id })
          }
          .asSingle()
			}
  }

  func fetchItem(id: Int) -> Single<AlgoliaItem> {
    return algoliaService.item(id: id)
  }
}

private extension Array {
  func sorted<C, Key>(relativeTo other: C, selector: (Element) -> Key) -> [Element] where C: Collection, C.Element == Key, Key: Equatable {
    return sorted { a, b in
      if let first = other.firstIndex(of: selector(a)), let second = other.firstIndex(of: selector(b)) {
        return first < second
      }
      return false
    }
  }
}
