//
//  QuizView2.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-05-06.
//

import SwiftUI

struct QuizView2: View {
    
    @Environment(\.dismiss) var dismiss
    
    

    var body: some View {
        
       
        
        ZStack {
            
            Color.teal
                .opacity(0.5)
                
                
            
            VStack {
                Text("Quiz View")
                    .font(.title)
                    .padding()
                    .background(.thinMaterial) // Set your desired 
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Close") {
                    dismiss()
                }
            }
            
        }
    }
}

#Preview {
    QuizView2()
}
