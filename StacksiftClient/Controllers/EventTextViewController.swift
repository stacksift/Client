import Cocoa
import ViewPlus

class EventTextViewController: XiblessViewController<NSScrollView> {
    private let textView = NSTextView()

    var text: NSAttributedString? {
        get { return representedObject as? NSAttributedString }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            if let text = text {
                textView.textStorage?.setAttributedString(text)
            }
        }
    }

    override func loadView() {
        textView.isEditable = false

        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.isRichText = false

        let max = CGFloat.greatestFiniteMagnitude

        textView.minSize = NSSize.zero
        textView.maxSize = NSSize(width: max, height: max)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width, .height]

        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.size = NSSize(width: max, height: max)

        self.view = NSScrollView()

        contentView.documentView = textView
    }
}
