//
//  FilterEditView.swift
//  Client
//
//  Created by Matthew Massicotte on 2021-07-26.
//

import SwiftUI
import Foundation
import Models

struct FilterEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var filterModel: FilterListViewModel
    @State var filter: Filter

    private func dismiss() {
        filterModel.saveEditedFilter(filter)

        presentationMode.wrappedValue.dismiss()
    }

    private func commaSeparatedBinding(_ source: Binding<Set<String>>) -> Binding<String> {
        return Binding {
            return source.wrappedValue.joined(separator: ",")
        } set: { string in
            source.wrappedValue = Set(string.components(separatedBy: ",").filter({ $0.count > 0 }))
        }
    }

    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $filter.title)
                TextField("Organizations", text: commaSeparatedBinding($filter.organizations))
                TextField("Hosts", text: commaSeparatedBinding($filter.hostExecutables))
                TextField("Builds", text: commaSeparatedBinding($filter.builds))
                TextField("Kinds", text: commaSeparatedBinding($filter.kinds))
                TextField("Versions", text: commaSeparatedBinding($filter.versions))
                TextField("Platforms", text: commaSeparatedBinding($filter.platforms))
                Picker("Time Window", selection: $filter.timeWindow) {
                    ForEach(Filter.TimeWindow.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }
            Button("OK") {
                self.dismiss()
            }
        }
        .padding()
        .frame(minWidth: 450)
    }
}

struct FilterEditView_Previews: PreviewProvider {
    static var previews: some View {
        FilterEditView(filter: Filter(title: "New Filter", timeWindow: .lastYear))
    }
}
