import SwiftUI

struct FilterEditForm: View {
    @Binding var filter: Filter

    private func commaSeparatedBinding(_ source: Binding<Set<String>>) -> Binding<String> {
        return Binding {
            return source.wrappedValue.joined(separator: ",")
        } set: { string in
            source.wrappedValue = Set(string.components(separatedBy: ",").filter({ $0.isEmpty == false }))
        }
    }

    var body: some View {
        Form {
            TextField("Title", text: $filter.title)
            TextField("Organizations", text: commaSeparatedBinding($filter.organizations))
            TextField("Hosts", text: commaSeparatedBinding($filter.hostExecutables))
            TextField("Kinds", text: commaSeparatedBinding($filter.kinds))
            Group {
                TextField("Versions", text: commaSeparatedBinding($filter.versions))
                TextField("Builds", text: commaSeparatedBinding($filter.builds))
            }
            Group {
                TextField("OS Builds", text: commaSeparatedBinding($filter.osBuilds))
                TextField("OS Versions", text: commaSeparatedBinding($filter.osVersions))
            }
            TextField("Devices", text: commaSeparatedBinding($filter.devices))
            TextField("Platforms", text: commaSeparatedBinding($filter.platforms))
            Picker("Time Window", selection: $filter.timeWindow) {
                ForEach(Filter.TimeWindow.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
        }
        .frame(minWidth: 450.0, alignment: .center)
    }
}

struct FilterEditForm_Previews: PreviewProvider {
    static var previews: some View {
        FilterEditForm(filter: .constant(Filter(title: "test", timeWindow: .lastYear)))
    }
}
