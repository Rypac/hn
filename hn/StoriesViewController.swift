import RxDataSources
import RxSwift
import UIKit

final class StoriesViewController: UIViewController {
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!

  private let viewModel = StoriesViewModel()
  private let disposeBag = DisposeBag()
  private let dataSource = RxCollectionViewSectionedReloadDataSource<StoriesViewModel.StorySection>(
    configureCell: { _, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(ofType: StoryCell.self, for: indexPath)
      cell.bind(story: item)
      return cell
    }
  )

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
    disposeBag.insert(
      viewModel.topStories
        .drive(collectionView.rx.items(dataSource: dataSource)),
      viewModel.loading
        .drive(activityIndicator.rx.isAnimating)
    )
  }
}
