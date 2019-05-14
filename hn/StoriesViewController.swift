import RxDataSources
import RxSwift
import UIKit

final class StoriesViewController: UIViewController, ViewModelAssignable {

  var viewModel: StoriesViewModel!

  @IBOutlet private var tableView: UITableView!
  private lazy var refresher = UIRefreshControl()

  private let disposeBag = DisposeBag()
  private let dataSource = RxTableViewSectionedAnimatedDataSource<StoriesViewModel.SectionModel>(
    configureCell: { _, tableView, indexPath, item in
      switch item {
      case let .story(story):
        let cell = tableView.dequeueReusableCell(ofType: StoryCell.self, for: indexPath)
        cell.bind(story: story)
        return cell
      case .loading:
        let cell = tableView.dequeueReusableCell(ofType: LoadingCell.self, for: indexPath)
        cell.load()
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if refresher.isRefreshing {
      refresher.beginRefreshing()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }

  private func configureDisplay() {
    tableView.refreshControl = refresher
    tableView.tableFooterView = UIView(frame: .zero)
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .bottom)
  }

  private func configurePresentation() {
    viewModel.title
      .drive(rx.title)
      .disposed(by: disposeBag)
    viewModel.loading
      .drive(refresher.rx.isRefreshing)
      .disposed(by: disposeBag)
    viewModel.topStories
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    viewModel.nextViewModel
      .drive(onNext: { [unowned self] viewModel in
        self.show(CommentsViewController.make(viewModel: viewModel), sender: nil)
      })
      .disposed(by: disposeBag)
  }

  private func configureInteraction() {
    refresher.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.refresh)
      .disposed(by: disposeBag)
    tableView.rx.itemSelected
      .bind(to: viewModel.selectedStory)
      .disposed(by: disposeBag)
    tableView.rx.prefetchRows
      .bind(to: viewModel.fetchNextStories)
      .disposed(by: disposeBag)
  }
}

extension StoriesViewController: StoryboardInstantiable {
  static var storyboardIdentifier: String {
    return "Stories"
  }
}