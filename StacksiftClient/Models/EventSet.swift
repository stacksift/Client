import Foundation

struct EventSet {
    var events: [Event]
    var visibleIds: [String]

    var visibleEvents: [Event] {
        return events.filter({ visibleIds.contains($0.id) })
    }

    var invisibleEvents: [Event] {
        return events.filter({ visibleIds.contains($0.id) == false })
    }

    static var empty: EventSet {
        return EventSet(events: [], visibleIds: [])
    }
}

extension EventSet: Hashable {
}

extension Report {
    var relationshipEventSet: EventSet {
        return EventSet(events: relationships, visibleIds: eventIds)
    }
}

