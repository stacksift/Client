import Foundation
import Cocoa
import SwiftUI
import Models

extension NSUserInterfaceItemIdentifier {
    static var eventTypeColumn = NSUserInterfaceItemIdentifier(rawValue: "eventType")
    static var eventModuleColumn = NSUserInterfaceItemIdentifier(rawValue: "eventModule")
    static var eventTitleColumn = NSUserInterfaceItemIdentifier(rawValue: "eventTitle")
    static var eventLinksColumn = NSUserInterfaceItemIdentifier(rawValue: "eventLinks")
    static var eventUsersColumn = NSUserInterfaceItemIdentifier(rawValue: "eventUsers")
    static var eventCountColumn = NSUserInterfaceItemIdentifier(rawValue: "eventCount")

    static var plainTextCell = NSUserInterfaceItemIdentifier(rawValue: "plainTextCell")
}

struct EventTableView: NSViewRepresentable {
    var events: [Event]
    @EnvironmentObject var contentViewModel: PathViewModel
    @Binding var activeEntry: PathEntry?

    func makeCoordinator() -> Coordinator {
        Coordinator(events: events, contentViewModel: contentViewModel, activeEntry: $activeEntry)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()

        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.target = context.coordinator
        tableView.doubleAction = #selector(Coordinator.doubleClickedTable(_:))

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
        tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        let typeColumn = NSTableColumn(identifier: .eventTypeColumn)
        typeColumn.width = 100.0
        typeColumn.title = "type"

        tableView.addTableColumn(typeColumn)

        let moduleColumn = NSTableColumn(identifier: .eventModuleColumn)
        moduleColumn.width = 140.0
        moduleColumn.title = "module"

        tableView.addTableColumn(moduleColumn)

        let titleColumn = NSTableColumn(identifier: .eventTitleColumn)
        titleColumn.minWidth = 100.0
        titleColumn.title = "title"

        tableView.addTableColumn(titleColumn)

        let linksColumn = NSTableColumn(identifier: .eventLinksColumn)
        linksColumn.minWidth = 35.0
        linksColumn.maxWidth = 45.0
        linksColumn.title = "links"

        tableView.addTableColumn(linksColumn)

        let usersColumn = NSTableColumn(identifier: .eventUsersColumn)
        usersColumn.minWidth = 30.0
        usersColumn.maxWidth = 35.0
        usersColumn.title = "users"

        tableView.addTableColumn(usersColumn)

        let countColumn = NSTableColumn(identifier: .eventCountColumn)
        countColumn.minWidth = 30.0
        countColumn.maxWidth = 35.0
        countColumn.title = "count"

        tableView.addTableColumn(countColumn)

        let view = NSScrollView()

        view.documentView = tableView

        return view
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let tableView = nsView.documentView as! NSTableView

        context.coordinator.events = events
        context.coordinator.contentViewModel = contentViewModel
        context.coordinator.activeEntry = $activeEntry

        tableView.reloadData()
    }
}

extension EventTableView {
    final class Coordinator: NSObject {
        var events: [Event]
        var contentViewModel: PathViewModel
        var activeEntry: Binding<PathEntry?>

        init(events: [Event], contentViewModel: PathViewModel, activeEntry: Binding<PathEntry?>) {
            self.events = events
            self.contentViewModel = contentViewModel
            self.activeEntry = activeEntry
        }

        @objc func doubleClickedTable(_ sender: Any) {
            let tableView = sender as! NSTableView
            let row = tableView.selectedRow
            if row < 0 {
                return
            }
            
            let event = events[row]

            let entry = PathEntry.report(event.reportId)
            contentViewModel.addEntry(entry)
            activeEntry.wrappedValue = entry
        }
    }
}

extension EventTableView.Coordinator: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return events.count
    }
}

extension EventTableView.Coordinator: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let reusedView = tableView.makeView(withIdentifier: .plainTextCell, owner: self)
        let view = reusedView as? NSTextField ?? NSTextField(labelWithString: "")

        let event = events[row]

        switch tableColumn?.identifier {
        case .eventTypeColumn?:
            view.stringValue = event.kindDisplayName
        case .eventModuleColumn?:
            view.stringValue = event.module
        case .eventTitleColumn?:
            view.stringValue = event.title
        case .eventLinksColumn?:
            view.stringValue = "\(event.metrics.relationships)/\(event.metrics.hostApps)"
        case .eventUsersColumn?:
            view.stringValue = String(event.metrics.users)
        case .eventCountColumn?:
            view.stringValue = String(event.metrics.occurrences)
        default:
            break
        }

        return view
    }
}
