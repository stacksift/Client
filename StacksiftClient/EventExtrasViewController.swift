import Cocoa
import ViewPlus
import SwiftUI

class EventExtrasViewController: XiblessViewController<NSScrollView> {
    typealias Content = EventSet

    private let tableView: NSTableView
    private var popover: NSPopover?

    var content: Content {
        didSet {
            tableView.reloadData()
        }
    }
    
    typealias ViewEventsAction = (EventSet) -> Void
    var viewEventsAction: ViewEventsAction?

    override init() {
        self.tableView = NSTableView()
        self.content = Content(events: [], visibleIds: [])

        super.init()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func loadView() {
        self.view = NSScrollView()

        tableView.addTableColumn(identifier: .eventTitleColumn, title: "title", minWidth: 30.0)
        tableView.headerView = nil

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
        tableView.usesAutomaticRowHeights = true
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

        let bounds = tableView.frameOfCell(atColumn: 0, row: row)

        let event = content.visibleEvents[row]

        let relationshipView = EventRelationshipDetailView(event: event, eventSet: content) { [unowned self] in
            self.popover?.close()
            self.viewEventsAction?(self.content)
        }

        popover?.close()

        popover = NSPopover()

        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: relationshipView)

        popover?.show(relativeTo: bounds, of: tableView, preferredEdge: NSRectEdge.maxY)
    }
}

extension EventExtrasViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let event = content.visibleEvents[row]

        let cell = tableColumn?.makeReusableView(generator: { () -> NSView in
            let uiView = EventRelationshipCellView(event: event)

            return NSHostingView(rootView: uiView)
        })

        return cell
    }
}

extension EventExtrasViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return content.visibleEvents.count
    }
}
