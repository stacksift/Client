import Cocoa

class BlockMenuItem: NSMenuItem {
    private var block: () -> Void

    init(title string: String, block: @escaping () -> Void) {
        self.block = block

        super.init(title: string, action: #selector(clickAction(_:)), keyEquivalent: "")

        self.target = self
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func clickAction(_ sender: Any?) {
        block()
    }
}

extension NSMenu {
    func addItem(title string: String, block: @escaping () -> Void) {
        addItem(BlockMenuItem(title: string, block: block))
    }

    func addSeparator() {
        addItem(NSMenuItem.separator())
    }
}
