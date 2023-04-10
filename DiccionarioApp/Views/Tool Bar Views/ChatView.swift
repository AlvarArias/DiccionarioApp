//
//  ChatView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-10.
//

import SwiftUI
import ChatGPTSwift

struct ChatView: View {
    
    let api = ChatGPTAPI(apiKey: "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")
    @State var chatresponse : [String] = [""]
    @State var palabra = ""
    
    var body: some View {
        VStack {
            
            Text("Wwite a word")
            TextField("palabra", text: $palabra)
                .padding()
                .cornerRadius(15)
                .background(Color.indigo)
            
            Button {
                print("tryChatGPT()")
                tryChatGPT(wordSelected: palabra)
                
            } label: {
                Image(systemName: "wand.and.stars")
            }
            Text("Synonim")
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    ForEach (chatresponse, id:\.self) { response in
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
    
    func tryChatGPT(wordSelected: String) {
        
        Task {
            do {
                let response = try await api.sendMessage(text: "give a bullet list with 2 synonym of \(wordSelected) in swedish and write 1 example ho to use it")
                print(response)
                chatresponse.append(response)
                palabra = ""
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
