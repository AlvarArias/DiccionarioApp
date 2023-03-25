//
//  LanguageSelectionView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct LanguageSelectionView: View {
    
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @Binding var selectedLang: Bool
    @Binding var errorMessage: String
    @Binding var showProgressBar: Bool
    
    var myviewModelWord: WordViewModel

    @State private var showNotification = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(LocalizedStringKey("selectlanguage"), isOn: $selectedLang)
                .tint(.orange).opacity(0.7)
                .font(.subheadline)

            HStack {
                Text(selectedLang == true ? "SWE -> SPA" : "SPA -> SWE")
                    .listRowSeparator(.hidden)
                    .font(.subheadline)

                //Text("\(errorMessage)")
                Text("")
                    .listRowSeparator(.hidden)
                    .onReceive(myviewModelWord.errorPublisher) { errorMessage in
                        self.errorMessage = errorMessage

                        if !errorMessage.isEmpty {
                            showProgressBar = false
                            
                            showNotification = true
                                                        
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showNotification = false
                                }
                            }
                        } 
                        
                    }
                    .font(.caption)

            }
        }
        .padding(10)
        .cornerRadius(10)
        .padding()
        .overlay(
                    Group {
                        if showNotification {
                            NotificationView(text: errorMessage)
                                .transition(.move(edge: .top))
                        }
                    }
                )
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
}

struct NotificationView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.white)
                .padding()
        }
        .frame(maxWidth: 100)
        .background(Color.orange.opacity(0.35))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

