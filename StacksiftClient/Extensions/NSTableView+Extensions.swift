import Cocoa

extension NSUserInterfaceItemIdentifier {
    static var textFieldCell = NSUserInterfaceItemIdentifier(rawValue: "textField")
}

extension NSTableView {
    func makeReusableLabelView() -> NSTextField {
        let view = makeView(withIdentifier: .textFieldCell, owner: nil) as? NSTextField

        return view ?? NSTextField(labelWithString: "")
    }
}

extension NSTableColumn {
    func makeReusableView<T: NSView>(owner: Any? = nil, generator: () -> T) -> T {
        let view = tableView!.makeView(withIdentifier: identifier, owner: owner)

        if let reusedView = view as? T {
            return reusedView
        }

        return generator()
    }

    func makeReusableView<T: NSView>(owner: Any? = nil) -> T {
        return makeReusableView(owner: self, generator: {
            return T()
        })
    }
}

extension NSTableColumn {
    func makeReusableLabel(owner: Any? = nil) -> NSTextField {
        return makeReusableView(owner: owner) {
            return NSTextField(labelWithString: "")
        }
    }
}

extension NSTableView {
    @discardableResult
    func addTableColumn(identifier: NSUserInterfaceItemIdentifier, title: String? = nil, minWidth: CGFloat? = nil) -> NSTableColumn {
        let column = NSTableColumn(identifier: identifier)

        if let title = title {
            column.title = title
        }

        if let width = minWidth {
            column.minWidth = width
        }

        addTableColumn(column)

        return column
    }
}

extension NSTableColumn {
    private var numberOfRows: Int {
        return tableView?.numberOfRows ?? 0
    }

    private var columnIndex: Int? {
        return tableView?.column(withIdentifier: identifier)
    }

    func setWidthToFitContents() {
        guard let columnIndex = columnIndex else { return }
        var newWidth = minWidth
        let spacing = tableView?.intercellSpacing.width ?? 0.0

        for rowIndex in 0..<numberOfRows {
            let view = tableView?.view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: true)

            let size = view?.intrinsicContentSize ?? .zero

            newWidth = max(newWidth, size.width)
            if newWidth >= maxWidth {
                break
            }
        }

        width = newWidth + spacing / 2.0
    }
}

class SizableTableCellView: NSTableCellView {
    override var intrinsicContentSize: NSSize {
        let textSize = textField?.intrinsicContentSize ?? .zero
        let imageSize = imageView?.intrinsicContentSize ?? .zero

        return NSSize(width: textSize.width + imageSize.width,
                      height: max(textSize.height, imageSize.height))
    }
}
