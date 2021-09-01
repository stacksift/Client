import Cocoa
import ViewPlus
import SwiftUI
import OperationPlus

class ColorView: NSView {
    var color: NSColor

    init(color: NSColor) {
        self.color = color

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        color.setFill()

        NSBezierPath.fill(dirtyRect)
    }
}

class SidebarViewController: XiblessViewController<NSView> {
    let navigationViewController = NavigationListViewController()

    override func loadView() {
        self.view = NSView()

        let navView = navigationViewController.view

        view.subviews = [navView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            navView.topAnchor.constraint(equalTo: view.topAnchor),
            navView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

class PlaceholderViewController: XiblessViewController<NSView> {
    override func loadView() {
        self.view = NSView()
    }
}

class MainViewController: XiblessViewController<NSView> {
    private let splitViewController: NSSplitViewController
    private let navigationCoordinator: NavigationCoordinator
    private let apiClient: APIClient

    init(networkService: NetworkService) {
        self.apiClient = APIClient(networkService: networkService)

        self.splitViewController = NSSplitViewController()
        self.navigationCoordinator = NavigationCoordinator(apiClient: apiClient)

        super.init()
    }

    private var contentViewController: ContentPresentingViewController {
        return navigationCoordinator.contentViewController
    }

    private var sidebarViewController: SidebarViewController {
        return navigationCoordinator.sidebarViewController
    }

    override func loadView() {
        self.view = NSView()

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarViewController)

        splitViewController.addSplitViewItem(sidebarItem)

        let contentItem = NSSplitViewItem(viewController: contentViewController)

        splitViewController.addSplitViewItem(contentItem)

        let splitView = splitViewController.view

        view.subviews = [splitView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            splitView.topAnchor.constraint(equalTo: view.topAnchor),
            splitView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            splitView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            splitView.widthAnchor.constraint(greaterThanOrEqualToConstant: 900.0),
            splitView.heightAnchor.constraint(greaterThanOrEqualToConstant: 600.0),
        ])
    }
}
