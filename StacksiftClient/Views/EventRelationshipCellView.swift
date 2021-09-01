import SwiftUI

struct EventRelationshipCellView: View {
    var event: Event

    var body: some View {
        HStack {
            Image(systemName: "die.face.1")
            VStack(alignment: .leading) {
                Text(event.kindDisplayName)
                    .bold()
                Text(event.title)
            }
        }
    }
}

struct EventRelationshipCellView_Previews: PreviewProvider {
    static var previews: some View {
        EventRelationshipCellView(event: Event(id: "1", kind: "something", title: "hello"))
    }
}
