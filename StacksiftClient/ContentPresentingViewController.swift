import Cocoa
import ViewPlus

class ContentPresentingViewController: XiblessViewController<NSView> {
    let placeholderViewController: PlaceholderViewController

    override init() {
        self.placeholderViewController = PlaceholderViewController()

        super.init()
    }

    override func loadView() {
        self.view = NSView()

        addInitialChild(placeholderViewController)
    }

    func addInitialChild(_ controller: NSViewController) {
        precondition(children.count == 0)

        addChild(controller)

        view.subviews = [controller.view]

        setupLayoutForChildController(controller)
    }

    func setupLayoutForChildController(_ controller: NSViewController) {
        let childView = controller.view

        childView.useAutoLayout = true

        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewController.TransitionOptions = [], completionHandler completion: (() -> Void)? = nil) {
        super.transition(from: fromViewController, to: toViewController, options: options, completionHandler: {
            self.setupLayoutForChildController(toViewController)

            completion?()
        })
    }

    private var presentedController: NSViewController? {
        return children.count <= 1 ? nil : children[1]
    }

    private var activeController: NSViewController {
        return presentedController ?? placeholderViewController
    }

    func resetToController(_ controller: NSViewController) {
        precondition(children.count < 3)
        precondition(controller.parent == nil)

        let outController = activeController
        let removingController = presentedController

        addChild(controller)

        transition(from: outController, to: controller, options: [.slideForward], completionHandler: {
            removingController?.removeFromParent()

            precondition(self.children.count == 2)
        })
    }

    func showController(_ controller: NSViewController, options: NSViewController.TransitionOptions = []) {
        precondition(children.count > 0)
        precondition(controller.parent == nil)

        let outController = activeController
        let removingController = presentedController

        addChild(controller)

        transition(from: outController, to: controller, options: options, completionHandler: {
            removingController?.removeFromParent()

            precondition(self.children.count == 2)
        })
    }

    func pushController(_ controller: NSViewController, completionHandler: (() -> Void)? = nil) {
        let currentController = children.last!

        precondition(controller.parent == nil)
        addChild(controller)

        transition(from: currentController, to: controller, options: .slideForward, completionHandler: completionHandler)
    }

    func popController(completionHandler: (() -> Void)? = nil) {
        precondition(children.count > 1)

        let outController = children.last!
        let inController = children[children.count-2]

        transition(from: outController, to: inController, options: .slideBackward, completionHandler: {
            completionHandler?()

            outController.removeFromParent()
        })
    }

    func popToInitialController(completionHandler: (() -> Void)? = nil) {
        precondition(children.count > 1)

        let outController = children.last!
        let inController = children.first!

        transition(from: outController, to: inController, options: .slideBackward, completionHandler: {
            completionHandler?()

            for child in self.children.dropFirst() {
                child.removeFromParent()
            }
        })
    }
}
