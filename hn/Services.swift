import Foundation

final class Services {
  let firebase: FirebaseService
  let algolia: AlgoliaService

  init(firebase: FirebaseService = FirebaseService(), algolia: AlgoliaService = AlgoliaService()) {
    self.firebase = firebase
    self.algolia = algolia
  }
}
