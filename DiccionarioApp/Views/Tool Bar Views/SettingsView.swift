//
//  SettingsView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var appEnvironment: AppEnvironment
    
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("hasApiKey") var hasApiKey: Bool = false

    var body: some View {
        NavigationView {
            Form {
                VStack {
                    Picker(LocalizedStringKey("language"), selection: $appEnvironment.currentLanguage) {
                        Text(LocalizedStringKey("english")).tag("en")
                        Text(LocalizedStringKey("swedish")).tag("sv")
                        Text(LocalizedStringKey("spanish")).tag("es")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                }
                /*
                HStack {
                    TextField("OpenAI API key", text: $apiKey)
                    
                    //Spacer()
                    
                    Button {
                      if apiKey.isEmpty == false {
                        hasApiKey = true
                      }
                    } label: {
                      Text("Submit")
                    }
                    
                }.padding()
                */
                
                Text(LocalizedStringKey("about"))
                    
                Text(LocalizedStringKey("developer:")) + Text ("  Alvar Arias" )
                    
                Text(LocalizedStringKey("lexin"))
                         
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(LocalizedStringKey("usersettings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.down")
                            .foregroundColor(Color.orange)
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(UIColor(red: 0.45, green: 0.92, blue: 0.84, alpha: 0.5)),
                            Color(UIColor(red: 0.67, green: 0.71, blue: 0.90, alpha: 0.5))
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .environment(\.locale, .init(identifier: appEnvironment.currentLanguage))
    }
       
}



/*
 7. Settings: The app may include a settings screen where users can customize setting:
 
- the default language
- font size
- preferences.
 
 8. Feedback: Some dictionary apps include a feedback mechanism where users can report errors or suggest new words or features.
 
 */

