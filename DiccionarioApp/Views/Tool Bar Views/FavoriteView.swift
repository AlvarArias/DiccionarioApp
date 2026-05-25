//
//  FavoriteView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-20.
//

import SwiftUI

struct FavoriteView: View {

    //MARK: Env
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) var dismiss

    @StateObject private var wordListViewModel = WordListViewModel()

    @Binding var searchWors: [String]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(searchWors, id: \.self) { word in
                        HStack {
                            Spacer()
                            Text(word)
                            Spacer()
                        }
                        .padding(15)
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        .foregroundColor(Color.onBackground)
                        .shadow(color: .gray, radius: 0.5, x: 0.5, y: -0.5)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(LocalizedStringKey("searchhistory"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.appPrimary)
                    }
                }
            }
            .background(Color.appBackground)
        }
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

#Preview {
    FavoriteView(searchWors: .constant([""]))
}
