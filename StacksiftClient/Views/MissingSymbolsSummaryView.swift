//
//  MissingSymbolsSummaryView.swift
//  StacksiftClient
//
//  Created by Matthew Massicotte on 2021-09-02.
//

import SwiftUI

struct MissingSymbolsSummaryView: View {
    var count: Int
    var action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text("Missing Symbols: \(count)")
        }
        .padding()
        .onTapGesture {
            action()
        }
    }
}

struct MissingSymbolsSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        MissingSymbolsSummaryView(count: 5, action: {})
    }
}
