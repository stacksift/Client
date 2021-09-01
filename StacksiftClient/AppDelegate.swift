import Cocoa
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: NSWindow!
    private let updateController = SPUStandardUpdaterController(updaterDelegate: nil, userDriverDelegate: nil)

    lazy var networkService: NetworkService = {
        let loader = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        return AuthenticatedNeworkService(loader: loader)
    }()

    lazy var mainViewController: MainViewController = {
        return MainViewController(networkService: self.networkService)
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupUserDefaults()
        
        self.mainWindow = NSWindow(contentViewController: mainViewController)

        mainWindow.minSize = NSSize(width: 100.0, height: 100.0)
        mainWindow.makeKeyAndOrderFront(self)
        mainWindow.center()
    }

    @IBAction func checkForUpdates(_ sender: Any?) {
        updateController.checkForUpdates(self)
    }
}

extension AppDelegate {
    private func setupUserDefaults() {
        let defaultFilters = Filter.defaultList.compactMap({ $0.toDictionary() })

        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
            "Filters": defaultFilters,
        ])
    }
}
