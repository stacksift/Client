import Cocoa
import ViewPlus

extension NSUserInterfaceItemIdentifier {
    static var frameNumberColumn = NSUserInterfaceItemIdentifier(rawValue: "frameNumber")
    static var frameModuleColumn = NSUserInterfaceItemIdentifier(rawValue: "frameModule")
    static var frameSymbolColumn = NSUserInterfaceItemIdentifier(rawValue: "frameSymbol")
    static var frameSourceLocationColumn = NSUserInterfaceItemIdentifier(rawValue: "frameSourceLocation")
}

struct DisplayableFrame {
    var frame: StackTraceFrame
    var highlighted: Bool

    var symbol: String? {
        return frame.symbol
    }

    var module: String {
        return frame.module
    }

    var fileBasename: String? {
        return frame.fileBasename
    }

    var line: Int? {
        return frame.line
    }

    var inlined: Bool {
        return false
    }

    var displaySourceLocation: String {
        switch (frame.fileBasename, frame.line) {
        case (let file?, let line?):
            return "\(file):\(line)"
        case (let file?, nil):
            return file
        default:
            return ""
        }
    }
}

class StacktraceFramesViewController: XiblessViewController<NSScrollView> {
    private let tableView: NSTableView

    override init() {
        self.tableView = NSTableView()

        super.init()
    }

    var frames: [DisplayableFrame] {
        get { return representedObject as? [DisplayableFrame] ?? [] }
        set {
            representedObject = newValue
            
            reloadAndResizeTable()
        }
    }

    override var representedObject: Any? {
        didSet {
            precondition(representedObject is [DisplayableFrame])
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
            .frameNumberColumn,
            .frameModuleColumn,
            .frameSymbolColumn,
            .frameSourceLocationColumn,
        ]

        identifiers.compactMap({ tableView.tableColumn(withIdentifier: $0) }).forEach { column in
            column.setWidthToFitContents()

//            column.maxWidth = column.width
        }

        // At this point, the table's columns might not quite be the right size. It takes a window
        // resize to fix it right now. But, there must be a way to manually trigger it...
    }

    override func loadView() {
        self.view = NSScrollView()

        tableView.addTableColumn(identifier: .frameNumberColumn, title: "number", minWidth: 30.0)
        tableView.addTableColumn(identifier: .frameModuleColumn, title: "module", minWidth: 50.0)
        tableView.addTableColumn(identifier: .frameSymbolColumn, title: "symbol", minWidth: 100.0)
        tableView.addTableColumn(identifier: .frameSourceLocationColumn, title: "location", minWidth: 100.0)
//        tableView.headerView = nil

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
        tableView.usesAutomaticRowHeights = true
        tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        // this is required to get stock NSTableCellView to look correct
        tableView.rowSizeStyle = .default

        contentView.documentView = tableView
    }
}

extension StacktraceFramesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: NSTextField = tableColumn!.makeReusableView {
            let field = NSTextField(wrappingLabelWithString: "")

            field.cell?.lineBreakMode = .byTruncatingTail
            field.cell?.truncatesLastVisibleLine = true

            return field
        }

        let plainAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.textColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12.0, weight: .regular)
        ]

        let accentedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.textColor,
            .font: NSFont.monospacedSystemFont(ofSize: 12.0, weight: .bold)
        ]

        let frame = frames[row]
        let attrs = frame.highlighted ? accentedAttrs : plainAttrs

        switch tableColumn?.identifier {
        case .frameNumberColumn?:
            cell.attributedStringValue = NSAttributedString(string: "\(row)", attributes: attrs)
        case .frameModuleColumn?:
            cell.attributedStringValue = NSAttributedString(string: frame.module, attributes: attrs)
        case .frameSymbolColumn?:
            let value = frame.symbol ?? ""

            cell.attributedStringValue = NSAttributedString(string: value, attributes: attrs)
        case .frameSourceLocationColumn?:
            cell.attributedStringValue = NSAttributedString(string: frame.displaySourceLocation, attributes: attrs)
        default:
            fatalError()
        }

        return cell
    }
}

extension StacktraceFramesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return frames.count
    }
}
