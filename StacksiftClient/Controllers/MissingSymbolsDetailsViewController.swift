import Cocoa
import ViewPlus

extension NSUserInterfaceItemIdentifier {
    static var symbolHostColumn = NSUserInterfaceItemIdentifier(rawValue: "symbolHost")
    static var symbolPathColumn = NSUserInterfaceItemIdentifier(rawValue: "symbolPath")
    static var symbolMapIdColumn = NSUserInterfaceItemIdentifier(rawValue: "symbolMapId")
    static var symbolVersionColumn = NSUserInterfaceItemIdentifier(rawValue: "eventLinks")
    static var symbolBuildColumn = NSUserInterfaceItemIdentifier(rawValue: "eventUsers")
}

class MissingSymbolsDetailsViewController: XiblessViewController<NSView> {
    private let tableView: NSTableView
    private let dismissButton: NSButton

    override init() {
        self.tableView = NSTableView()
        self.dismissButton = NSButton(title: "OK", target: nil, action: #selector(NSViewController.dismiss(_:) as (NSViewController) -> (Any?) -> Void))

        super.init()
    }

    var missingSymbols: [MissingSymbol] {
        get { return representedObject as? [MissingSymbol] ?? []}
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            reload()
        }
    }

    private func reload() {
        tableView.reloadData()
        adjustColumns()
    }

    private func adjustColumns() {
        let identifiers: [NSUserInterfaceItemIdentifier] = [
            .symbolHostColumn,
            .symbolMapIdColumn,
            .symbolVersionColumn,
            .symbolBuildColumn,
        ]

        tableView.sizeColumnsToFit(with: identifiers)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        tableView.delegate = self
        tableView.dataSource = self

        adjustColumns()
    }

    override func loadView() {
        self.view = NSView()

        let scrollView = NSScrollView()

        tableView.addTableColumn(identifier: .symbolHostColumn, title: "Executable", minWidth: 100.0)
        tableView.addTableColumn(identifier: .symbolVersionColumn, title: "Version", minWidth: 30.0)
        tableView.addTableColumn(identifier: .symbolBuildColumn, title: "Build", minWidth: 30.0)
        tableView.addTableColumn(identifier: .symbolMapIdColumn, title: "UUID", minWidth: 120.0)
        tableView.addTableColumn(identifier: .symbolPathColumn, title: "Path", minWidth: 50.0)

        tableView.allowsColumnReordering = false
        tableView.allowsMultipleSelection = false
        tableView.allowsColumnSelection = false
        tableView.allowsColumnResizing = true
        tableView.usesAutomaticRowHeights = true
        tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

        // this is required to get stock NSTableCellView to look correct
        tableView.rowSizeStyle = .default

        scrollView.documentView = tableView

        view.subviews = [scrollView, dismissButton]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: 10.0),

            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0),

            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 750.0),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 250.0),
        ])
    }
}

extension MissingSymbolsDetailsViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let missingSymbol = missingSymbols[row]

        let cell: NSTableCellView = tableColumn!.makeReusableView {
            let cellView = SizableTableCellView()

            let field = NSTextField(labelWithString: "")

            cellView.textField = field

            cellView.addSubview(field)

            return cellView
        }

        switch tableColumn?.identifier {
        case .symbolHostColumn?:
            cell.textField?.stringValue = missingSymbol.executable
        case .symbolPathColumn?:
            cell.textField?.stringValue = missingSymbol.path
        case .symbolMapIdColumn?:
            cell.textField?.stringValue = missingSymbol.id
        case .symbolVersionColumn?:
            cell.textField?.stringValue = missingSymbol.version.version
        case .symbolBuildColumn?:
            cell.textField?.stringValue = missingSymbol.version.build
        default:
            fatalError()
        }

        return cell
    }
}

extension MissingSymbolsDetailsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return missingSymbols.count
    }
}
