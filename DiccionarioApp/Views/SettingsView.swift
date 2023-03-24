//
//  SettingsView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-24.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        Form {
            Section(header: Text("User Settings")) {
                
              Text("User language")
             //TextField("Name", text: $userLanguage)
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

/*
 7. Settings: The app may include a settings screen where users can customize setting:
 
- the default language
- font size
- preferences.
 
 8. Feedback: Some dictionary apps include a feedback mechanism where users can report errors or suggest new words or features.
 
 */

