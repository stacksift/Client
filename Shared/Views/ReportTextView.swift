import SwiftUI

struct ReportTextView: NSViewRepresentable {
    let text: NSAttributedString

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()

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

        let view = NSScrollView()

        view.documentView = textView

        return view
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView

        textView.textStorage?.setAttributedString(text)
    }
}
