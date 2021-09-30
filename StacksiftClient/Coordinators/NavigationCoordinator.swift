import Cocoa

class NavigationCoordinator {
    let contentViewController: ContentPresentingViewController
    let sidebarViewController: SidebarViewController
    let apiClient: APIClient

    private var content: [NavigationListViewController.Entry] {
        didSet {
            var navContent = navigationContent

            navContent.entries = content

            navigationContent = navContent
        }
    }

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        self.contentViewController = ContentPresentingViewController()
        self.sidebarViewController = SidebarViewController(apiClient: apiClient)

        self.content = []

        navigationContent = .init(filters: loadFilters(), entries: [])

        navigationViewController.filterSelectionAction = { [unowned self] (filter, _) in
            self.filterChanged(filter)
        }

        navigationViewController.entrySelectionAction = { [unowned self] (entry, index) in
            self.entryChanged(entry, at: index)
        }

        navigationViewController.filterEditAction = { [unowned self] (newFilter, idx) in
            var navContent = navigationContent

            navContent.filters[idx] = newFilter

            self.navigationContent = navContent

            saveFilters()
        }

        navigationViewController.createFilterAction = { [unowned self] (newFilter, _) in
            var navContent = navigationContent

            navContent.filters.append(newFilter)

            self.navigationContent = navContent

            saveFilters()
        }

        navigationViewController.deleteFilterAction = { [unowned self] (_, row) in
            var navContent = navigationContent

            navContent.filters.remove(at: row)

            self.navigationContent = navContent

            saveFilters()
        }
    }

    var navigationViewController: NavigationListViewController {
        return sidebarViewController.navigationViewController
    }

    private var navigationContent: NavigationListViewController.Content {
        get { navigationViewController.content }
        set { navigationViewController.content = newValue }
    }

    private func saveFilters() {
        let dictionaries = navigationContent.filters.compactMap({ $0.toDictionary() })

        UserDefaults.standard.set(dictionaries, forKey: "Filters")
    }
}

extension NavigationCoordinator {
    private func loadFilters() -> [Filter] {
        guard let value = UserDefaults.standard.array(forKey: "Filters") as? [[String: Any]] else {
            return Filter.defaultList
        }

        let decodedFilters = value.compactMap({ Filter.fromDictionary($0) })

        guard decodedFilters.count > 0 else {
            return Filter.defaultList
        }

        return decodedFilters
    }

    private func advanceToController(_ vc: NSViewController, for entry: NavigationListViewController.Entry) {
        contentViewController.showController(vc, options: [.slideForward])
        content.append(entry)
    }

    private func makeEventContentController(for event: Event) -> EventContentViewController {
        let client = apiClient

        let eventController = EventContentViewController(apiClient: client, event: event)

        eventController.viewEventsAction = { (eventSet) in
            let eventsController = self.makeEventsViewController(for: .eventSet(event, eventSet))

            self.advanceToController(eventsController, for: .relationships(event, eventSet))
        }

        return eventController
    }

    private func makeEventsViewController(for content: EventsViewController.Content) -> EventsViewController {
        let client = apiClient

        let controller = EventsViewController(apiClient: client, content: content)

        controller.eventSelectedHandler = { event in
            let eventController = self.makeEventContentController(for: event)

            self.advanceToController(eventController, for: .event(event))
        }

        return controller
    }

    private func filterChanged(_ filter: Filter) {
        // clear content first
        content = []

        let controller = makeEventsViewController(for: .filter(filter))

        contentViewController.resetToController(controller)
    }

    private func entryChanged(_ entry: NavigationListViewController.Entry, at index: Int) {
        // determine which entries we need to remove
        precondition(index < content.count)

        let suffixCount = content.count - 1 - index

        content.removeLast(suffixCount)

        let navEntry = content.last!

        precondition(navEntry == entry)

        let controller: NSViewController

        switch entry {
        case .event(let event):
            controller = makeEventContentController(for: event)
        case .relationships(let event, let eventSet):
            controller = makeEventsViewController(for: .eventSet(event, eventSet))
        }

        contentViewController.showController(controller, options: [.slideBackward])
    }
}
