import IGListKit
import ReSwift
import SafariServices
import UIKit

final class ItemDetailsViewController: UIViewController {
    struct ReuseId {
        static let postCell = "Post"
        static let commentCell = "Comments"
    }

    let tableView = UITableView()
    var state: ItemDetailsViewModel

    var cachedHeights = [Int: CGFloat]()

    fileprivate lazy var prototypeCommentCell: CommentCell =
        self.tableView.dequeueReusableCell(withIdentifier: ReuseId.commentCell) as! CommentCell // swiftlint:disable:this force_cast

    init(state: ItemDetailsViewModel) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ItemDetailCell.self, forCellReuseIdentifier: ReuseId.postCell)
        tableView.register(CommentCell.self, forCellReuseIdentifier: ReuseId.commentCell)

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)

        view.addSubview(tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemDetailsViewModel(details: state.selectedItem!, repo: state.repository)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == .none {
            store.dispatch(ItemListNavigationAction.dismiss(state.parent))
        }
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(state.requestComments)
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        let oldComments = state.comments
        state = newState
        title = newState.title

        switch newState.fetching {
        case .none:
            tableView.refreshControl?.beginRefreshing()
            store.dispatch(state.requestComments)
        case .finished?:
            tableView.refreshControl?.endRefreshing()
        default:
            break
        }

        let diff = ListDiffPaths(
            fromSection: 1,
            toSection: 1,
            oldArray: oldComments,
            newArray: state.comments,
            option: .equality)
        if diff.hasChanges {
            tableView.beginUpdates()
            for indexPath in diff.updates {
                if let cell = tableView.cellForRow(at: indexPath) as? CommentCell {
                    cell.bind(viewModel: state.comments[indexPath.row])
                }
            }
            tableView.deleteRows(at: diff.deletes, with: .fade)
            tableView.insertRows(at: diff.inserts, with: .fade)
            for move in diff.moves {
                tableView.moveRow(at: move.from, to: move.to)
            }
            tableView.endUpdates()
        }
    }
}

extension ItemDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == ItemDetailsViewModel.Section.comments.rawValue
            ? state.comments.count
            : 1
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == ItemDetailsViewModel.Section.comments.rawValue
            ? heightForRow(withModel: state.comments[indexPath.row])
            : 200
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == ItemDetailsViewModel.Section.comments.rawValue
            ? heightForRow(withModel: state.comments[indexPath.row])
            : UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseId.postCell, for: indexPath)

            if let cell = cell as? ItemDetailCell {
                cell.bind(viewModel: state.parent)
            }

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseId.commentCell, for: indexPath)

            if let cell = cell as? CommentCell {
                let comment = state.comments[indexPath.row]
                cell.bind(viewModel: comment)
            }

            return cell
        }
    }
}

extension ItemDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.as(ItemDetailsViewModel.Section.self) {
        case .parent?:
            if let viewOriginalAction = routeTo(original: state.parent, from: self) {
                store.dispatch(viewOriginalAction)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemDetailsViewController {
    func heightForRow(withModel model: CommentViewModel) -> CGFloat {
        if let height = cachedHeights[model.comment.id] {
            return height
        }

        prototypeCommentCell.bind(viewModel: model)

        let size = CGSize(width: tableView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let textHeight = ceil(prototypeCommentCell.commentText.attributedText.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            context: nil).size.height)
        let detailsHeight = ceil(prototypeCommentCell.commentDetails.attributedText.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            context: nil).size.height)

        let height = textHeight + detailsHeight + 8
        cachedHeights[model.comment.id] = height
        return height
    }
}
