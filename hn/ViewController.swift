import Bond
import ReactiveKit
import UIKit

class ViewController: UIViewController {
  private let viewModel = ViewModel()

  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    configureDisplay()
    configurePresentation()
  }

  private func configureDisplay() {
    collectionView.alwaysBounceVertical = true
    collectionView.contentInsetAdjustmentBehavior = .always
  }

  private func configurePresentation() {
    viewModel.topStories
      .consumeLoadingState(by: self)
      .bind(to: collectionView) { stories, indexPath, collectionView in
        let cell = collectionView.dequeueReusableCell(ofType: NameCell.self, for: indexPath)
        cell.bind(story: stories[indexPath.item])
        return cell
      }
  }
}

extension ViewController: LoadingStateListener {
  public func setLoadingState<LoadingValue, LoadingError>(_ state: ObservedLoadingState<LoadingValue, LoadingError>) {
    switch state {
    case .loading, .reloading:
      activityIndicator.startAnimating()
    case .loaded:
      activityIndicator.stopAnimating()
    case .failed(let error):
      print("Failed: \(error)")
    }
  }
}
