//
//  WordInfoView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct WordInfoView: View {
    let result: Result
    let saveWordToCoreData: () -> Void

    var body: some View {
        HStack {
            Text(result.value ?? "No value")
                .font(.headline)
                .listRowSeparator(.hidden)

            Text("(\(result.type ?? "No type"))")
                .font(.subheadline)

            Spacer(minLength: 10)

            Button(action: {
                // Save to core data
                saveWordToCoreData()
            }) {
                Image(systemName: "plus")
            }
        }
        .listRowSeparator(.hidden)
    }
}
