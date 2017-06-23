import UIKit
import AsyncDisplayKit
import ReSwift
import SafariServices

final class ItemListViewController:
    ASViewController<ASDisplayNode>,
    ASTableDataSource,
    ASTableDelegate,
    UIGestureRecognizerDelegate,
    StoreSubscriber
{
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    let itemType: ItemType
    var fetchingMore = false
    var hasMoreItems = true
    var items = [Item]()
    var fetchingContext: ASBatchContext?

    init(_ storyType: ItemType) {
        self.itemType = storyType
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.leadingScreensForBatching = 1

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPressOnStory(gesture:)))
        longPressGesture.minimumPressDuration = 1
        longPressGesture.delegate = self
        tableNode.view.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = itemType.description
        store.subscribe(self) { subscription in
            subscription.select { state in (state.tabs[self.itemType]!, state.selectedItem) }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 0)

        if fetchingMore && indexPath.row == rowCount - 1 {
            return {
                let node = LoadingCellNode()
                node.style.height = ASDimensionMake(44.0)
                return node
            }
        }

        let item = items[indexPath.row]
        return {
            return ItemCellNode(item)
        }
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return fetchingMore ? items.count + 1 : items.count
    }

    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return hasMoreItems
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.fetchingContext = context
        store.dispatch(fetchItems(itemType))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = items[indexPath.row]
        store.dispatch(routeTo(story, from: self))
    }

    func didLongPressOnStory(gesture: UILongPressGestureRecognizer) {
        if
            gesture.state == UIGestureRecognizerState.began,
            let index = tableNode.indexPathForRow(at: gesture.location(in: tableNode.view))
        {
            let story = items[index.row]
            tableNode.selectRow(at: index, animated: false, scrollPosition: .none)
            store.dispatch(routeTo(original: story, from: self))
        }
    }

    func newState(state: (ItemList, ItemDetails?)) {
        let (state, selectedItem) = state
        let wasFetchingMore = fetchingMore
        let oldItems = items
        fetchingMore = state.fetchingMore
        items = state.items
        hasMoreItems = state.ids.count == 0 || state.items.count < state.ids.count

        tableNode.performBatchUpdates({
            let rowCountChange = items.count - oldItems.count
            if rowCountChange > 0 {
                let indexPaths = (oldItems.count..<items.count).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            }

            if fetchingMore != wasFetchingMore {
                if fetchingMore {
                    tableNode.insertRows(
                        at: [IndexPath(row: state.items.count, section: 0)],
                        with: .none)
                } else {
                    tableNode.deleteRows(
                        at: [IndexPath(row: oldItems.count, section: 0)],
                        with: .none)
                    fetchingContext?.completeBatchFetching(true)
                }
            }
        }, completion: nil)

        if
            case .none = selectedItem,
            let selectedRow = tableNode.indexPathForSelectedRow
        {
            tableNode.deselectRow(at: selectedRow, animated: true)
        }
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListAction.dismissOriginal)
    }
}
