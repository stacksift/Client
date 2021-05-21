//
//  SidebarView.swift
//  Client
//
//  Created by Matthew Massicotte on 2021-04-06.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        SidebarContentView()
            .listStyle(SidebarListStyle())
            .frame(idealWidth: 250)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
