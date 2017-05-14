import UIKit

class StoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Identifiers {
        static let PostCell = "PostCell"
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.PostCell)
        return tableView
    }()

    var stories = [Story]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        fetchTopStories()
    }

    func fetchTopStories() {
        fetchIds(.topStories) { [weak self] ids in
            ids.prefix(upTo: 20).forEach {
                fetch(.item($0)) { (story: Story) in
                    self?.stories.append(story)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
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
