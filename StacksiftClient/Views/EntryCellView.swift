//
//  EntryCellView.swift
//  StacksiftClient
//
//  Created by Matthew Massicotte on 2021-08-27.
//

import SwiftUI

struct EntryCellView: View {
    var imageName: String
    var title: String
    var subtitle: String? = nil

    var body: some View {
        HStack {
            Image(systemName: imageName)
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                if subtitle?.isEmpty == false {
                    Text(subtitle ?? "")
                }
            }
        }
        .padding([.vertical], 3.0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EntryCellView_Previews: PreviewProvider {
    static var previews: some View {
        EntryCellView(imageName: "line.horizontal.3.decrease.circle", title: "Title", subtitle: "Subtitle")
    }
}
