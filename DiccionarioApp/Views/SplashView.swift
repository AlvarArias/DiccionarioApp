//
//  SplashView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

import SwiftUI

struct SplashView: View {
    @State private var showNextView = false

    var body: some View {
        NavigationView {
            VStack {
                if showNextView {
                    // The view you want to show after the splash screen
                   WordView()
                    
                } else {
                    // Splash screen with image
                    Image("dixio")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        //.edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showNextView = true
                    }
                }
            }
          
        }
       
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
