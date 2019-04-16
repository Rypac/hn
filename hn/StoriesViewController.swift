import RxDataSources
import RxSwift
import UIKit

final class StoriesViewController: UITableViewController {

  var viewModel: StoriesViewModel!

  private lazy var refresher = UIRefreshControl()
  private let disposeBag = DisposeBag()
  private let dataSource = RxTableViewSectionedAnimatedDataSource<StoriesViewModel.SectionModel>(
    configureCell: { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(ofType: StoryCell.self, for: indexPath)
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if refresher.isRefreshing {
      refresher.beginRefreshing()
    }
  }

  private func configureDisplay() {
    refreshControl = refresher
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
        self.performSegue(withIdentifier: "showComments", sender: viewModel)
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
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? CommentsViewController, let viewModel = sender as? CommentsViewModel {
      viewController.viewModel = viewModel
    }
  }
}
