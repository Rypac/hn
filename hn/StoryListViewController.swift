import UIKit

class StoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Identifiers {
        static let PostCell = "PostCell"
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = self.refreshControl
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.PostCell)
        return tableView
    }()

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchTopStories), for: .valueChanged)
        return refreshControl
    }()

    var stories = [Story]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        fetchTopStories()
    }

    func fetchTopStories() {
        stories = []
        tableView.reloadData()
        fetch(.topStories) { [weak self] (ids: [Int]) in
            ids.prefix(upTo: 20).forEach {
                fetch(.item($0)) { (story: Story) in
                    DispatchQueue.main.async {
                        self?.stories.append(story)
                        if let count = self?.stories.count, count % 20 == 0 {
                            self?.tableView.reloadData()
                            self?.refreshControl.endRefreshing()
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let story = stories[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.PostCell, for: indexPath)
        cell.textLabel?.text = story.title
        return cell
    }
}
