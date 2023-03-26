//
//  Notifications.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-26.
//


import SwiftUI

// Problems notification
struct NotificationView: View {
    let text: String
    /*
    var text: LocalizedStringKey
    init(text: LocalizedStringKey) {
            self.text = text
        }
    */
    var body: some View {
        HStack {
            Text(text)
                .foregroundColor(.white)
                .padding()
        }
        
        .frame(minWidth: 100)
        .background(Color.orange.opacity(0.35))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        
    }
}

// Ok Notification
struct NotificationCore: View {

    var text: LocalizedStringKey
    init(text: LocalizedStringKey) {
            self.text = text
        }
    
    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(.white)
                .padding()
        }
        
        .frame(minWidth: 100)
        .background(Color.blue.opacity(0.35))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
        
    }
}
