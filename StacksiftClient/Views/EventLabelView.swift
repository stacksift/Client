//
//  EventLabelView.swift
//  StacksiftClient
//
//  Created by Matthew Massicotte on 2021-09-01.
//

import SwiftUI

struct EventLabelView: View {
    let event: Event

    var backgroundColor: Color {
        textColor.opacity(0.5)
    }

    var textColor: Color {
        switch event.group {
        case .frame:
            return Color("frame-label")
        case .watchdog, .exception, .memory:
            return Color("exception-label")
        default:
            return Color("note-label")
        }
    }

    var label: String {
        return event.group.name
    }

    var body: some View {
        Text(label.uppercased())
            .foregroundColor(textColor)
            .lineLimit(1)
            .padding(EdgeInsets(top: 2.0, leading: 10.0, bottom: 2.0, trailing: 10.0))
            .background(backgroundColor)
            .cornerRadius(4.0)
    }
}

struct EventLabelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EventLabelView(event: Event(id: "1", kind: "frame.deepest-interesting", title: "title"))
            EventLabelView(event: Event(id: "2", kind: "exception", title: "title"))
            EventLabelView(event: Event(id: "3", kind: "note.mach_msg_trap", title: "title"))
            EventLabelView(event: Event(id: "3", kind: "note.8badf00d", title: "title"))
        }
    }
}
