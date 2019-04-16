import RxDataSources
import RxSwift
import UIKit

final class CommentsViewController: UITableViewController {

  var viewModel: CommentsViewModel!

  private lazy var refresher = UIRefreshControl()
  private let disposeBag = DisposeBag()
  private let dataSource = RxTableViewSectionedAnimatedDataSource<CommentsViewModel.SectionModel>(
    configureCell: { _, tableView, indexPath, item in
      switch item {
      case let .post(post):
        let cell = tableView.dequeueReusableCell(ofType: PostCell.self, for: indexPath)
        cell.bind(post: post)
        return cell
      case let .comment(comment):
        let cell = tableView.dequeueReusableCell(ofType: CommentCell.self, for: indexPath)
        cell.bind(comment: comment)
        return cell
      }
    }
  )

  override func viewDidLoad() {
    super.viewDidLoad()

    configureDisplay()
    configurePresentation()
    configureInteraction()
  }

  private func configureDisplay() {
    refreshControl = refresher
  }

  private func configurePresentation() {
    viewModel.title
      .drive(rx.title)
      .disposed(by: disposeBag)
    viewModel.loading
      .skip(1)
      .drive(refresher.rx.isRefreshing)
      .disposed(by: disposeBag)
    viewModel.comments
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

  private func configureInteraction() {
    refresher.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.refresh)
      .disposed(by: disposeBag)
  }
}
