import RxDataSources
import RxSwift
import SafariServices
import UIKit

final class CommentsViewController: UIViewController, ViewModelAssignable {

  var viewModel: CommentsViewModel!

  @IBOutlet private var tableView: UITableView!
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }

  private func configureDisplay() {
    tableView.refreshControl = refresher

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
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
    viewModel.url
      .drive(onNext: { [unowned self] url in
        self.present(SFSafariViewController(url: url), animated: true)
      })
      .disposed(by: disposeBag)
  }

  private func configureInteraction() {
    refresher.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.refresh)
      .disposed(by: disposeBag)
    navigationItem.rightBarButtonItem?.rx.tap
      .bind(to: viewModel.viewStory)
      .disposed(by: disposeBag)
  }
}

extension CommentsViewController: StoryboardInstantiable {
  static var storyboardIdentifier: String {
    return "Comments"
  }
}
