import RxDataSources
import RxSwift
import UIKit

final class CommentsViewController: UIViewController {
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet private var activityIndicator: UIActivityIndicatorView!

  var viewModel: CommentsViewModel!

  private let disposeBag = DisposeBag()
  private let dataSource = RxCollectionViewSectionedReloadDataSource<CommentsViewModel.CommentSection>(
    configureCell: { _, collectionView, indexPath, item in
      switch item {
      case let .post(post):
        let cell = collectionView.dequeueReusableCell(ofType: PostCell.self, for: indexPath)
        cell.bind(post: post)
        return cell
      case let .comment(comment):
        let cell = collectionView.dequeueReusableCell(ofType: CommentCell.self, for: indexPath)
        cell.bind(comment: comment)
        return cell
      }
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
    viewModel.comments
      .drive(collectionView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}
