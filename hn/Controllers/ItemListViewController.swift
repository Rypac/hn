import IGListKit
import ReSwift
import SafariServices
import UIKit

final class ItemListViewController: UIViewController, UIGestureRecognizerDelegate {
    struct ReuseId {
        static let postCell = "Post"
    }

    let tableView = UITableView()
    var state: ItemListViewModel

    init(state: ItemListViewModel) {
        self.state = state
        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ItemCell.self, forCellReuseIdentifier: ReuseId.postCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        tableView.addGestureRecognizer(longPressGesture)

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let type = state.itemType
        parent?.title = type.description
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemListViewModel(type: type, list: state.tabs[type]!, repo: state.repository)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(state.requestItemList)
    }

    func longPress(gesture: UILongPressGestureRecognizer) {
        guard
            gesture.state == UIGestureRecognizerState.began,
            let index = tableView.indexPathForRow(at: gesture.location(in: tableView))
        else {
            return
        }

        let story = state.posts[index.row].post
        if let viewOriginalAction = routeTo(original: story, from: self) {
            store.dispatch(viewOriginalAction)
        }
    }
}

extension ItemListViewController: StoreSubscriber {
    func newState(state newState: ItemListViewModel) {
        let oldPosts = state.posts
        state = newState

        switch newState.fetching {
        case .none:
            tableView.refreshControl?.beginRefreshing()
            store.dispatch(state.requestItemList)
        case .list(.finished)?:
            store.dispatch(state.requestNextItemBatch)
        case .items(.finished)?:
            tableView.refreshControl?.endRefreshing()
        default:
            break
        }

        let diff = ListDiffPaths(
            fromSection: 0,
            toSection: 0,
            oldArray: oldPosts,
            newArray: state.posts,
            option: .equality)
        if diff.hasChanges {
            tableView.beginUpdates()
            tableView.deleteRows(at: diff.deletes, with: .none)
            tableView.insertRows(at: diff.inserts, with: .none)
            for move in diff.moves {
                tableView.moveRow(at: move.from, to: move.to)
            }
            tableView.reloadRows(at: diff.updates, with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension ItemListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseId.postCell, for: indexPath)

        if let cell = cell as? ItemCell {
            let post = state.posts[indexPath.row].post
            cell.bind(viewModel: post)
        }

        return cell
    }
}

extension ItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = state.posts[indexPath.row].post
        store.dispatch(routeTo(story, from: self))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListNavigationAction.dismissOriginal)
    }
}
