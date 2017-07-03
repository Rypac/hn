import AsyncDisplayKit
import Dwifft

extension SectionedValues {
    var sections: [Section] { return sectionsAndValues.map { $0.0 } }

    subscript(i: Int) -> (Section, [Value]) {
        return sectionsAndValues[i]
    }
}

class ASTableNodeDiffCalculator<Section: Equatable, Value: Equatable> {
    weak var tableNode: ASTableNode?
    private var _sectionedValues: SectionedValues<Section, Value>

    var insertionAnimation: UITableViewRowAnimation
    var deletionAnimation: UITableViewRowAnimation

    init(
        tableNode: ASTableNode? = .none,
        initialSectionedValues: SectionedValues<Section, Value> = SectionedValues(),
        insertionAnimation: UITableViewRowAnimation = .none,
        deletionAnimation: UITableViewRowAnimation = .none
    ) {
        self.tableNode = tableNode
        self.insertionAnimation = insertionAnimation
        self.deletionAnimation = deletionAnimation
        _sectionedValues = initialSectionedValues
    }

    func numberOfSections() -> Int {
        return sectionedValues.sections.count
    }

    func value(forSection: Int) -> Section {
        return sectionedValues[forSection].0
    }

    func numberOfObjects(inSection section: Int) -> Int {
        return sectionedValues[section].1.count
    }

    func value(atIndexPath indexPath: IndexPath) -> Value {
        return sectionedValues[indexPath.section].1[indexPath.row]
    }

    var sectionedValues: SectionedValues<Section, Value> {
        get {
            return _sectionedValues
        }
        set {
            let oldSectionedValues = sectionedValues
            let newSectionedValues = newValue
            let diff = Dwifft.diff(lhs: oldSectionedValues, rhs: newSectionedValues)
            if !diff.isEmpty {
                processChanges(newState: newSectionedValues, diff: diff)
            }
        }
    }

    func processChanges(newState: SectionedValues<Section, Value>, diff: [SectionedDiffStep<Section, Value>]) {
        guard let tableNode = tableNode else {
            return
        }

        tableNode.performBatchUpdates({
            _sectionedValues = newState
            for result in diff {
                switch result {
                case let .delete(section, row, _):
                    tableNode.deleteRows(at: [IndexPath(row: row, section: section)], with: deletionAnimation)
                case let .insert(section, row, _):
                    tableNode.insertRows(at: [IndexPath(row: row, section: section)], with: insertionAnimation)
                case let .sectionDelete(section, _):
                    tableNode.deleteSections(IndexSet(integer: section), with: deletionAnimation)
                case let .sectionInsert(section, _):
                    tableNode.insertSections(IndexSet(integer: section), with: insertionAnimation)
                }
            }
        })
    }
}
