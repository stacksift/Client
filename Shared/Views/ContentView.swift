//
//  ContentView.swift
//  Shared
//
//  Created by Matthew Massicotte on 2021-04-06.
//

import SwiftUI
import Models

struct ContentView: View {
    @StateObject var pathModel: PathViewModel
    @Binding var editingFilter: Filter

    init(editingFilter: Binding<Filter>) {
        self._editingFilter = editingFilter
        self._pathModel = StateObject(wrappedValue: PathViewModel())
    }

    var body: some View {
        NavigationView {
            SidebarView(editingFilter: $editingFilter)
            Text("path content")
                .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigation){
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
        }
        .environmentObject(pathModel)
    }

    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.contentViewController?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(editingFilter: .constant(Filter.newFilter))
    }
}
