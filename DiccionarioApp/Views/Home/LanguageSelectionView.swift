//
//  LanguageSelectionView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct LanguageSelectionView: View {
    
    @Binding var selectedLang: Bool
    @Binding var errorMessage: String
    @Binding var showProgressBar: Bool
    
    var myviewModelWord: WordViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Select Language", isOn: $selectedLang)
                .tint(.orange).opacity(0.7)
                .font(.subheadline)

            HStack {
                Text(selectedLang == true ? "SWE -> SPA" : "SPA -> SWE")
                    .listRowSeparator(.hidden)
                    .font(.subheadline)

                Text("\(errorMessage)")
                    .listRowSeparator(.hidden)
                    .onReceive(myviewModelWord.errorPublisher) { errorMessage in
                        self.errorMessage = errorMessage

                        if !errorMessage.isEmpty {
                            showProgressBar = false
                        } 
                        
                    }
                    .font(.caption)
            }
        }
        .padding(10)
        .cornerRadius(10)
        .padding()
    }
}
