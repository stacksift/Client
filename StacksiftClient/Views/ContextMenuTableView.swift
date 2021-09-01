import Cocoa

class ContextMenuTableView: NSTableView {
    public var menuProvider: ((NSTableView, Int) -> NSMenu?)?
    public var activeMenu: NSMenu?

    public var hasActiveMenu: Bool {
        return activeMenu != nil
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        guard let provider = menuProvider else {
            self.activeMenu = nil

            return super.menu(for: event)
        }

        let point = convert(event.locationInWindow, from: nil)
        let eventRow = row(at: point)

        guard eventRow >= 0 else {
            self.activeMenu = nil

            return nil
        }

        let menu = provider(self, eventRow)

        self.activeMenu = menu

        if menu != nil {
            selectRowIndexes(IndexSet([eventRow]), byExtendingSelection: false)
        }

        return menu
    }

    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        selectRowIndexes(IndexSet(), byExtendingSelection: false)

        activeMenu = nil
    }
}
