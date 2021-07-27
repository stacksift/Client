//
//  SidebarView.swift
//  Client
//
//  Created by Matthew Massicotte on 2021-04-06.
//

import SwiftUI
import Models

struct SidebarView: View {
    @Binding var editingFilter: Filter

    var body: some View {
        SidebarContentView(editingFilter: $editingFilter)
            .listStyle(SidebarListStyle())
            .frame(idealWidth: 250)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(editingFilter: .constant(Filter.newFilter))
    }
}
