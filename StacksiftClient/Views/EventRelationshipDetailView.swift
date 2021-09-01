import SwiftUI

struct EventRelationshipDetailView: View {
    var event: Event
    var eventSet: EventSet
    var viewEventsAction: () -> Void

    var invisibleCount: Int {
        return eventSet.invisibleEvents.count
    }

    var totalCount: Int {
        return eventSet.visibleIds.count + invisibleCount
    }

    var body: some View {
        VStack(alignment: .center) {
            EventLabelView(event: event)
                .padding()
            Text(event.kindDisplayName)
                .bold()
            Text(event.title)
                .padding(.bottom)

            Text("Relationships: \(invisibleCount)/\(totalCount)")
            Button("View Related Events") {
                viewEventsAction()
            }
            .disabled(invisibleCount <= 0)

            Text(event.kindDisplayDescription)
                .frame(width: 350.0)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }
        .padding()
    }
}

struct EventRelationshipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventRelationshipDetailView(event: Event(id: "1", kind: "frame.deepest-interesting", title: "some long title"),
                                        eventSet: EventSet(events: [], visibleIds: []),
                                        viewEventsAction: {})
            EventRelationshipDetailView(event: Event(id: "1", kind: "frame.deepest-interesting", title: "some long title"),
                                        eventSet: EventSet(events: [], visibleIds: []),
                                        viewEventsAction: {})
                .frame(width: 450, height: 600)
        }
    }
}
