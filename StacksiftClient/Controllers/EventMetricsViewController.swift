import Cocoa
import ViewPlus

extension NSUserInterfaceItemIdentifier {
    static var versionColumn = NSUserInterfaceItemIdentifier(rawValue: "versionColumn")
    static var buildColumn = NSUserInterfaceItemIdentifier(rawValue: "buildColumn")
    static var modelColumn = NSUserInterfaceItemIdentifier(rawValue: "modelColumn")
    static var countColumn = NSUserInterfaceItemIdentifier(rawValue: "countColumn")
}

class EventMetricsViewController: XiblessViewController<NSView> {
    private let hostVersionTable: NSTableView
    private let osVersionTable: NSTableView
    private let deviceModelTable: NSTableView

    override init() {
        self.hostVersionTable = NSTableView()
        self.osVersionTable = NSTableView()
        self.deviceModelTable = NSTableView()

        super.init()
    }
    
    var report: Report? {
        get { return representedObject as? Report }
        set { representedObject = newValue }
    }

    var metrics: [EventOccurrenceMetrics]? {
        get { return representedObject as? [EventOccurrenceMetrics] }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            reload()
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        for tableView in tableViews {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    override func loadView() {
        self.view = NSView()

        let hostScrollView = NSScrollView()
        let osScrollView = NSScrollView()
        let deviceScrollView = NSScrollView()

        for tableView in tableViews {
            tableView.allowsColumnReordering = false
            tableView.allowsMultipleSelection = false
            tableView.allowsColumnSelection = false
            tableView.allowsColumnResizing = true
            tableView.usesAutomaticRowHeights = true
            tableView.columnAutoresizingStyle = .sequentialColumnAutoresizingStyle

            // this is required to get stock NSTableCellView to look correct
            tableView.rowSizeStyle = .default
        }

        hostVersionTable.addTableColumn(identifier: .versionColumn, title: "Version")
        hostVersionTable.addTableColumn(identifier: .buildColumn, title: "Build")
        hostVersionTable.addTableColumn(identifier: .countColumn, title: "Count", minWidth: 30.0)

        osVersionTable.addTableColumn(identifier: .versionColumn, title: "OS")
        osVersionTable.addTableColumn(identifier: .buildColumn, title: "Build")
        osVersionTable.addTableColumn(identifier: .countColumn, title: "Count", minWidth: 30.0)

        deviceModelTable.addTableColumn(identifier: .modelColumn, title: "Model")
        deviceModelTable.addTableColumn(identifier: .countColumn, title: "Count", minWidth: 40.0)

        hostScrollView.documentView = hostVersionTable
        osScrollView.documentView = osVersionTable
        deviceScrollView.documentView = deviceModelTable

        view.subviews = [hostScrollView, osScrollView, deviceScrollView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            hostScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            hostScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostScrollView.heightAnchor.constraint(equalToConstant: 120.0),

            osScrollView.topAnchor.constraint(equalTo: hostScrollView.bottomAnchor, constant: -10.0),
            osScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            osScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            osScrollView.heightAnchor.constraint(equalToConstant: 120.0),

            deviceScrollView.topAnchor.constraint(equalTo: osScrollView.bottomAnchor, constant: -10.0),
            deviceScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            deviceScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deviceScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deviceScrollView.heightAnchor.constraint(equalToConstant: 120.0),
        ])
    }

    private var tableViews: [NSTableView] {
        return [hostVersionTable, osVersionTable, deviceModelTable]
    }

    private func reload() {
        tableViews.forEach({ $0.reloadData() })

        if let column = deviceModelTable.tableColumn(withIdentifier: .countColumn) {
            column.setWidthToFitContents()

            let spacing = deviceModelTable.intercellSpacing.width
            let width = deviceModelTable.visibleRect.width - column.width - spacing

            deviceModelTable.tableColumn(withIdentifier: .modelColumn)?.width = width
        }

        osVersionTable.tableColumn(withIdentifier: .countColumn)?.setWidthToFitContents()
        osVersionTable.tableColumn(withIdentifier: .versionColumn)?.setWidthToFitContents()

        if let column = hostVersionTable.tableColumn(withIdentifier: .countColumn) {
            column.setWidthToFitContents()

            let spacing = deviceModelTable.intercellSpacing.width
            let width = (hostVersionTable.visibleRect.width - column.width) / 2.0 - spacing * 2.0

            hostVersionTable.tableColumn(withIdentifier: .versionColumn)?.width = width
            hostVersionTable.tableColumn(withIdentifier: .buildColumn)?.width = width
        }
    }

    private var osVersions: [EventOccurrenceMetrics.VersionMetric] {
        let versions = metrics?.flatMap({ $0.osVersions }) ?? []

        return versions.sorted(by: { a, b in
            a.count > b.count
        })
    }

    private var hostVersions: [EventOccurrenceMetrics.VersionMetric] {
        let versions = metrics?.flatMap({ $0.hostVersions }) ?? []

        return versions.sorted(by: { a, b in
            a.count > b.count
        })
    }

    private var deviceModels: [EventOccurrenceMetrics.ModelMetric] {
        let devices = metrics?.flatMap({ $0.deviceModels }) ?? []

        return devices.sorted(by: { a, b in
            a.count > b.count
        })
    }
}

extension EventMetricsViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: NSTableCellView = tableColumn!.makeReusableView {
            let cellView = SizableTableCellView()

            let field = NSTextField(labelWithString: "")

            cellView.textField = field

            cellView.addSubview(field)

            return cellView
        }

        switch tableView {
        case hostVersionTable:
            let version = hostVersions[row]

            switch tableColumn?.identifier {
            case .versionColumn?:
                cell.textField?.stringValue = version.version.version
            case .buildColumn?:
                cell.textField?.stringValue = version.version.build
            case .countColumn?:
                cell.textField?.stringValue = "\(version.count)"
            default:
                fatalError()
            }
        case osVersionTable:
            let version = osVersions[row]

            switch tableColumn?.identifier {
            case .versionColumn?:
                cell.textField?.stringValue = version.version.version
            case .buildColumn?:
                cell.textField?.stringValue = version.version.build
            case .countColumn?:
                cell.textField?.stringValue = "\(version.count)"
            default:
                fatalError()
            }
        case deviceModelTable:
            let device = deviceModels[row]

            switch tableColumn?.identifier {
            case .modelColumn?:
                cell.textField?.stringValue = device.model
            case .countColumn?:
                cell.textField?.stringValue = "\(device.count)"
            default:
                fatalError()
            }
        default:
            fatalError()
        }

        return cell
    }
}

extension EventMetricsViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case hostVersionTable:
            return hostVersions.count
        case osVersionTable:
            return osVersions.count
        case deviceModelTable:
            return deviceModels.count
        default:
            fatalError()
        }
    }
}
