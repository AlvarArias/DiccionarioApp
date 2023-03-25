//
//  ResultListView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct ResultsListView: View {
    
    @Binding var selectedLang: Bool
    @Binding var isVStackVisible: Bool
    @Binding var showProgressBar: Bool
    var myviewModelWord: WordViewModel

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(myviewModelWord.results, id: \.self) { result in
                NavigationLink(destination: DetailView(selectedLang: $selectedLang, result: result)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(result.value ?? "No value")
                                .font(.headline)
                            Spacer()

                            Text(result.type ?? "No type")
                                .font(.subheadline)
                        }
                        .padding(5)

                        if selectedLang {
                            VStack {
                                Text(result.targetLang?.translation ?? "no translation").font(.caption)
                            }
                        } else {
                            VStack {
                                Text(result.baseLang?.meaning ?? "No meaning").font(.caption)
                            }
                        }
                    }
                    .padding(15)
                    .background(Color(UIColor.white).opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .foregroundColor(Color.black)
                    .shadow(color: .gray, radius: 0.5, x: 0.5, y: -0.5)
                }
            }
        }
        .opacity(isVStackVisible ? 1.0 : 0.0)
        .animation(.easeIn(duration: 1.0), value: isVStackVisible)
        .onAppear {
            withAnimation {
                isVStackVisible = true
            }
            showProgressBar = false
        }
    }
}
