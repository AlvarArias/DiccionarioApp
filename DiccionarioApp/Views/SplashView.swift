//
//  SplashView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct SplashView: View {
    @State private var showNextView = false

    var body: some View {
        VStack {
            if showNextView {
                WordView()
            } else {
                Image("dixio")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(2.0))
                withAnimation(.easeInOut(duration: 0.5)) {
                    showNextView = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
