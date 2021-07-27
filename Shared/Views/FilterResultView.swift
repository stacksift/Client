//
//  FilterResultView.swift
//  Client
//
//  Created by Matthew Massicotte on 2021-04-08.
//

import SwiftUI
import Models
import SiftServices

struct FilterResultView: View {
    var activeEntry: Binding<PathEntry?>
    @StateObject private var model: FilterResultsViewModel
    @StateObject private var timeseriesModel: TimeseriesResultsViewModel

    init(services: Services, filter: Filter, activeEntry: Binding<PathEntry?>) {
        self._model = StateObject(wrappedValue: FilterResultsViewModel(services: services, filter: filter))
        self._timeseriesModel = StateObject(wrappedValue: TimeseriesResultsViewModel(services: services, filter: filter))
        self.activeEntry = activeEntry
    }

    private func reload() {
        model.reload()
        timeseriesModel.reload()
    }

    var body: some View {
        VStack {
            Text(model.title)
            ChartView(data: timeseriesModel.results)
                .frame(maxWidth: .infinity, maxHeight: 256.0)
            EventTableView(events: model.results, activeEntry: activeEntry)
                    .frame(minWidth: 100.0, minHeight: 100.0, idealHeight: 100.0)
                .onAppear {
                    reload()
                }
        }
    }
}

#if DEBUG
import MockServiceImplemenations

struct FilterResultView_Previews: PreviewProvider {
    static var previews: some View {
        let filter = Filter(title: "default", timeWindow: .lastYear)

        return FilterResultView(services: Services.mock, filter: filter, activeEntry: .constant(.filter(filter)))
    }
}

#endif
