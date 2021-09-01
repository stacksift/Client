//
//  EventListView.swift
//  StacksiftClient
//
//  Created by Matthew Massicotte on 2021-08-25.
//

import SwiftUI

struct EventListView: NSViewControllerRepresentable {
    typealias NSViewControllerType = EventListViewController
    let apiClient: APIClient

    func makeNSViewController(context: Context) -> EventListViewController {
        return EventListViewController(apiClient: apiClient, filter: Filter.defaultList.first!)
    }

    func updateNSViewController(_ nsViewController: EventListViewController, context: Context) {
    }
}

