//
//  LanguageInfoView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct LanguageInfoView: View {
    
    let result: Result
    let selectedLang: Bool

    var body: some View {
        if selectedLang {
            VStack(alignment: .leading) {
                HStack {
                    Text(result.targetLang?.translation ?? "no translation")
                }
                .listRowSeparator(.hidden)

                HStack {
                    Text(result.targetLang?.synonym?.first ?? "")
                }
                .listRowSeparator(.hidden)
            }
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Text(result.baseLang?.meaning ?? "no translation")
                }
                .listRowSeparator(.hidden)

                HStack {
                    Text(result.baseLang?.inflection?[0].content ?? "")
                    Spacer(minLength: 5)
                    Text(result.baseLang?.inflection?[1].content ?? "")
                }
                .listRowSeparator(.hidden)
            }
        }
    }
}

