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
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Form {
                Text("Write a word" )
                
                HStack {
                    TextField("palabra", text: $palabra)
                    
                    Button {
                        print("Button tryChatGPT()")
                        print(apiKey)
                        print(palabra)
                        viewModel.tryChatGPT(wordSelected: palabra)
                        
                    } label: {
                        Image(systemName: "wand.and.stars")
                    }
                }
            }
            Text("Synonim")
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    ForEach (viewModel.chatresponse, id:\.self) { response in
                        VStack {
                            Text(response).font(.caption)
                                .cornerRadius(15)
                                .padding()
                        }

                    }
                }
            }
        }
    }
        
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
