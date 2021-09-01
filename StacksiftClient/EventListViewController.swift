import Cocoa
import ViewPlus
import Combine
import SwiftUI

extension NSUserInterfaceItemIdentifier {
    static var eventTypeColumn = NSUserInterfaceItemIdentifier(rawValue: "eventType")
    static var eventModuleColumn = NSUserInterfaceItemIdentifier(rawValue: "eventModule")
    static var eventTitleColumn = NSUserInterfaceItemIdentifier(rawValue: "eventTitle")
    static var eventLinksColumn = NSUserInterfaceItemIdentifier(rawValue: "eventLinks")
    static var eventUsersColumn = NSUserInterfaceItemIdentifier(rawValue: "eventUsers")
    static var eventCountColumn = NSUserInterfaceItemIdentifier(rawValue: "eventCount")

    static var plainTextColumnCell = NSUserInterfaceItemIdentifier(rawValue: "label")
}

class EventListViewController: XiblessViewController<NSScrollView> {
    private let tableView: NSTableView

    var eventSelectedHandler: ((Event) -> Void)?

    init(events: [Event] = []) {
        self.tableView = NSTableView()

        super.init()

        self.events = events
    }

    var events: [Event] {
        get { representedObject as! [Event] }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            precondition(representedObject is [Event])

            reloadAndResizeTable()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func reloadAndResizeTable() {
        tableView.reloadData()

        let identifiers: [NSUserInterfaceItemIdentifier] = [
            .eventTypeColumn,
            .eventModuleColumn,
            .eventLinksColumn,
            .eventUsersColumn,
            .eventCountColumn,
        ]

        var usedWidth: CGFloat = 0

        identifiers.compactMap({ tableView.tableColumn(withIdentifier: $0) }).forEach { column in
            column.setWidthToFitContents()

            column.maxWidth = column.width
            usedWidth += column.width
        }

        // At this point, the table's columns might not quite be the right size. It takes a window
        // resize to fix it right now. But, there must be a way to manually trigger it...
    }

    override func loadView() {
        self.view = NSScrollView()

        tableView.addTableColumn(identifier: .eventTypeColumn, title: "type", minWidth: 50.0)
        tableView.addTableColumn(identifier: .eventModuleColumn, title: "module", minWidth: 50.0)
        tableView.addTableColumn(identifier: .eventTitleColumn, title: "title", minWidth: 100.0)
        tableView.addTableColumn(identifier: .eventLinksColumn, title: "links", minWidth: 30.0)
        tableView.addTableColumn(identifier: .eventUsersColumn, title: "users", minWidth: 30.0)
        tableView.addTableColumn(identifier: .eventCountColumn, title: "count", minWidth: 30.0)

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
//        tableView.usesAutomaticRowHeights = true
        tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        // this is required to get stock NSTableCellView to look correct
        tableView.rowSizeStyle = .default

        tableView.target = self
        tableView.doubleAction = #selector(eventDoubleClicked(_:))

        contentView.documentView = tableView
    }

    @objc private func eventDoubleClicked(_ sender: Any?) {
        precondition(tableView === (sender as? NSTableView))

        let row = tableView.selectedRow
        if row < 0 {
            return
        }

        let event = events[row]

        eventSelectedHandler?(event)
    }
}

extension EventListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let event = events[row]

        if tableColumn?.identifier == .eventTypeColumn {
            let cellView = tableColumn!.makeReusableView {
                return NSHostingView(rootView: EventLabelView(event: event))
            }

            cellView.rootView = EventLabelView(event: event)

            return cellView
        }

        let cell: NSTableCellView = tableColumn!.makeReusableView {
            let cellView = SizableTableCellView()

            let field = NSTextField(labelWithString: "")

            cellView.textField = field

            cellView.addSubview(field)

            return cellView
        }

        switch tableColumn?.identifier {
        case .eventModuleColumn?:
            cell.textField?.stringValue = event.module
        case .eventTitleColumn?:
            cell.textField?.stringValue = event.title
        case .eventLinksColumn?:
            cell.textField?.stringValue = "\(event.metrics.relationships)/\(event.metrics.hostApps)"
        case .eventUsersColumn?:
            cell.textField?.stringValue = String(event.metrics.users)
        case .eventCountColumn?:
            cell.textField?.stringValue = String(event.metrics.occurrences)
        default:
            fatalError()
        }

        return cell
    }
}

extension EventListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return events.count
    }
}
