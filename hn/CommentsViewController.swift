import RxDataSources
import RxSwift
import UIKit

final class CommentsViewController: UITableViewController {

  var viewModel: CommentsViewModel!

  private let disposeBag = DisposeBag()
  private let dataSource = RxTableViewSectionedReloadDataSource<CommentsViewModel.CommentSection>(
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

    configurePresentation()
  }

  private func configurePresentation() {
    viewModel.title
      .drive(rx.title)
      .disposed(by: disposeBag)
    viewModel.comments
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }
}
