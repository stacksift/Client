import Cocoa
import ViewPlus
import SwiftUI

extension NSUserInterfaceItemIdentifier {
    static var filterListEntryColumn = NSUserInterfaceItemIdentifier(rawValue: "filter")
}

class NavigationListViewController: XiblessViewController<NSScrollView> {
    enum Entry: Hashable {
        case event(Event)
        case relationships(Event, EventSet)

        var title: String {
            switch self {
            case .event:
                return "Report"
            case .relationships:
                return "Relationships"
            }
        }

        var subtitle: String {
            switch self {
            case .event(let event):
                return event.reportId
            case .relationships(let event, _):
                return event.title
            }
        }

        var imageName: String {
            switch self {
            case .event:
                return "doc.text"
            case .relationships:
                return "list.bullet"
            }
        }
    }

    struct Content {
        var filters: [Filter]
        var entries: [Entry]
    }

    enum Item {
        case nothing
        case entry(Entry)
        case filter(Filter)
    }

    private let tableView: ContextMenuTableView

    typealias Action = (Item) -> Void

    typealias FilterAction = (Filter, Int) -> Void
    typealias EntryAction = (Entry, Int) -> Void

    var filterSelectionAction: FilterAction?
    var entrySelectionAction: EntryAction?
    var filterEditAction: FilterAction?
    var createFilterAction: FilterAction?
    var deleteFilterAction: FilterAction?
    private var reloading: Bool = false

    override init() {
        self.tableView = ContextMenuTableView()

        super.init()

        self.content = Content(filters: [], entries: [])
        
        tableView.menuProvider = { [unowned self] (_, row) in
            let item = self.getNavigationItem(for: row)

            guard case .filter = item else {
                return nil
            }

            let menu = NSMenu()

            menu.addItem(title: "Edit") { [unowned self] in
                self.editFilter(at: row)
            }

            menu.addItem(title: "Delete…") { [unowned self] in
                let alert = NSAlert()

                alert.addButton(withTitle: "Delete")
                alert.addButton(withTitle: "Cancel")
                alert.messageText = "Are you sure you want to delete \"filter\"?"
                alert.informativeText = "This operation cannot be undone."

                alert.beginSheetModal(for: self.view.window!) { response in
                    self.deleteFilter(at: row)
                }
            }

            return menu
        }
    }

    var content: Content {
        get { representedObject as! Content }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            precondition(representedObject is Content)

            reload()
        }
    }

    private func reload() {
        reloading = true
        defer {
            reloading = false
        }

        let indices = tableView.selectedRowIndexes
        tableView.reloadData()
        
        tableView.selectRowIndexes(indices, byExtendingSelection: false)

        if content.entries.count > 0 {
            let lastRow = tableView.numberOfRows - 1

            tableView.selectRowIndexes(IndexSet(integer: lastRow), byExtendingSelection: false)
        }
    }

    private func editFilter(at row: Int) {
        let item = self.getNavigationItem(for: row)

        guard case .filter(let filter) = item else {
            fatalError()
        }

        let controller = FilterEditViewController(filter: filter)

        self.presentAsSheet(controller)

        controller.responseHandler = { [unowned controller] (response, newFilter) in
            self.dismiss(controller)

            guard response == .OK else { return }

            let idx = row - 1

            self.filterEditAction?(newFilter, idx)
        }
    }

    private func deleteFilter(at row: Int) {
        let item = self.getNavigationItem(for: row)

        guard case .filter(let filter) = item else {
            fatalError()
        }

        let idx = row - 1

        deleteFilterAction?(filter, idx)
    }

    override func viewWillAppear() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func loadView() {
        self.view = NSScrollView()

        let column = NSTableColumn(identifier: .filterListEntryColumn)
        column.minWidth = 40.0

        tableView.addTableColumn(column)

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true

        // this is required to get stock NSTableCellView to look correct
        tableView.rowSizeStyle = .default

        contentView.documentView = tableView
    }

    private func getNavigationItem(for row: Int) -> Item {
        var index = row

        if index <= 0 {
            return .nothing
        }

        index -= 1

        if index < content.filters.count {
            return .filter(content.filters[index])
        }

        index -= content.filters.count

        if index == 0 {
            return .nothing
        }

        index -= 1

        return .entry(content.entries[index])
    }

    private var filterGroupRow: Int {
        return 0
    }

    private var pathGroupRow: Int {
        return content.filters.count + 1
    }

    private var shouldInvokeSelectionAction: Bool {
        return reloading == false && tableView.hasActiveMenu == false
    }
}

extension NavigationListViewController {
    @IBAction func newFilter(_ sender: Any?) {
        let filter = Filter(title: "New Filter", kinds: Set(), hostExecutables: Set(), timeWindow: .last30Days, platforms: Set(), organizations: Set())
        let controller = FilterEditViewController(filter: filter)

        self.presentAsSheet(controller)

        controller.responseHandler = { [unowned controller] (response, newFilter) in
            self.dismiss(controller)

            guard response == .OK else { return }

            self.createFilterAction?(newFilter, -1)
        }
    }
}

extension NavigationListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else {
            let groupLabel = NSTextField(labelWithString: "")

            switch row {
            case filterGroupRow:
                groupLabel.stringValue = "Filters"
            case pathGroupRow:
                groupLabel.stringValue = "Path"
            default:
                fatalError()
            }

            return groupLabel
        }

        let item = getNavigationItem(for: row)
        let entryView: EntryCellView

        switch item {
        case .entry(let entry):
            entryView = EntryCellView(imageName: entry.imageName, title: entry.title, subtitle: entry.subtitle)
        case .filter(let filter):
            entryView = EntryCellView(imageName: "line.horizontal.3.decrease.circle", title: filter.title)
        case .nothing:
            fatalError()
        }

        let cellView: NSHostingView = column.makeReusableView {
            return NSHostingView(rootView: entryView)
        }

        return cellView
    }

    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return row == filterGroupRow || row == pathGroupRow
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard shouldInvokeSelectionAction else { return }

        let row = tableView.selectedRow
        let item = getNavigationItem(for: row)

        switch item {
        case .nothing:
            return
        case .filter(let filter):
            filterSelectionAction?(filter, row - 1)
        case .entry(let entry):
            let entryIndex = row - 2 - content.filters.count

            entrySelectionAction?(entry, entryIndex)
        }
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return self.tableView(tableView, isGroupRow: row) == false
    }
}

extension NavigationListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return content.filters.count + 1 + content.entries.count + 1
    }
}
