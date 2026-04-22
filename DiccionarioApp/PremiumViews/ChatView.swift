//
//  ChatView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-10.
//

import SwiftUI
import ChatGPTSwift


struct ChatView: View {
    
    @AppStorage("apiKey") var apiKey: String = ""
    @State var palabra = ""
    @ObservedObject var openAPIviewModel = ViewModel()
    
    var body: some View {
        VStack {
            Form {
                Text("Write a word" )
                
                HStack {
                    TextField("palabra", text: $palabra)
                    
                    Button {
                        print("viewModel.tryChatGPT(wordSelected: palabra)")
                        openAPIviewModel.tryChatGPT(wordSelected: palabra)
                        
                    } label: {
                        Image(systemName: "wand.and.stars")
                    }
                }
            }
            Text("Synonim")
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    ForEach(openAPIviewModel.chatResponse, id: \.self) { response in
                        Text(response)
                            .font(.caption)
                            .padding()
                    }
                }
            }
        }
    }
        
}

#Preview {
    ChatView()
}
