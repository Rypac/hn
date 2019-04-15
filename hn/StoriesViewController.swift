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
    configureInteraction()
  }

  private func configureDisplay() {
    collectionView.alwaysBounceVertical = true
    collectionView.contentInsetAdjustmentBehavior = .always
  }

  private func configurePresentation() {
    viewModel.topStories
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    viewModel.loading
      .drive(activityIndicator.rx.isAnimating)
      .disposed(by: disposeBag)
    viewModel.nextViewModel
      .drive(onNext: { [unowned self] viewModel in
        self.performSegue(withIdentifier: "showComments", sender: viewModel)
      })
      .disposed(by: disposeBag)
  }

  private func configureInteraction() {
    collectionView.rx.itemSelected
      .bind(to: viewModel.selectedStory)
      .disposed(by: disposeBag)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? CommentsViewController, let viewModel = sender as? CommentsViewModel {
      viewController.viewModel = viewModel
    }
  }
}
