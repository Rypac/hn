import Foundation
import RxSwift

class StoryRepository {
	private let firebaseService: FirebaseService
	private let algoliaService: AlgoliaService

  init(firebaseService: FirebaseService = FirebaseService(), algoliaService: AlgoliaService = AlgoliaService()) {
    self.firebaseService = firebaseService
		self.algoliaService = algoliaService
  }

  func fetchTopStories() -> Single<[Item]> {
		return firebaseService.topStories()
			.flatMap { [algoliaService] (items: [Int]) -> Single<[Item]> in
				let firstTenStories = items.prefix(2).map(algoliaService.item(id:))
        return Observable.from(firstTenStories).merge().toArray().asSingle()
          .map { stories in (0..<20).flatMap { _ in stories } }
			}
  }
}
