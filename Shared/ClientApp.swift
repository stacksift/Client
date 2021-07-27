import SwiftUI
import SiftServices
import ServiceImplemenations
import Models
import MockServiceImplemenations
import Sparkle

extension Services {
    init() {
        let loader = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let service = AuthenticatedNeworkService(loader: loader)
        
        self.init(networkService: service)
    }
}

struct ServicesKey: EnvironmentKey {
    static var defaultValue = Services()
//    static var defaultValue = mockDefaults

    static var mockDefaults: Services {
        let netService = MockNetworkService()

        let event1 = Event(id: "event-1", kind: "frame.deepest-interesting", title: "Event 1")

        netService.addMockResponse("https://api.stacksift.io/v1/events", encodable: [event1])

        let report1 = Report(id: "report-1")

        netService.addMockResponse("https://api.stacksift.io/v1/reports/report-1", encodable: report1)

        let event2 = Event(id: "event-2", kind: "frame.deepest-interesting", title: "Event 2")

        netService.addMockResponse("https://api.stacksift.io/v1/events", encodable: [event2])

        return Services(networkService: netService)
    }
}

extension EnvironmentValues {
    var services: Services {
        get { self[ServicesKey.self] }
    }
}

extension NSNotification.Name {
    static let RefreshData = Notification.Name("RefreshData")
}

@main
struct ClientApp: App {
    @State var pathModel = PathViewModel()
    @State var editingFilter = Filter.newFilter
    @State var editingFilterPresented = false
    @StateObject var filterModel: FilterListViewModel
    private var updateController: SPUStandardUpdaterController

    init() {
        self.updateController = SPUStandardUpdaterController(updaterDelegate: nil, userDriverDelegate: nil)
        self._filterModel = StateObject(wrappedValue: FilterListViewModel())

        let defaultFilters = Filter.defaultList.compactMap({ $0.toDictionary() })

        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
            "Filters": defaultFilters,
        ])
    }

    var isEditing: Binding<Bool> {
        return Binding {
            return filterModel.editingState != .idle
        } set: { value in
            if value == false {
                filterModel.editingState = .idle
            }
        }

    }
    var body: some Scene {
        WindowGroup {
            ContentView(editingFilter: $editingFilter)
                .sheet(isPresented: isEditing) {
                    FilterEditView(filter: filterModel.editingFilter)
                }
                .onChange(of: editingFilter) { _ in
                    self.isEditing.wrappedValue = true
                }
                .environmentObject(pathModel)
                .environmentObject(filterModel)
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: CommandGroupPlacement.appSettings) {
                Button("Check for Update…") {
                    self.updateController.checkForUpdates(self)
                }
            }
            CommandGroup(after: CommandGroupPlacement.sidebar) {
                Divider()
                Button("Reload") {
                    NotificationCenter.default.post(name: .RefreshData, object: nil)
                }
                .keyboardShortcut("r")
                Divider()
            }
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Divider()
                Button("New Filter…") {
                    self.filterModel.editingState = .newFilter
                    self.isEditing.wrappedValue = true
                }
                Divider()
            }
        }
    }
}
