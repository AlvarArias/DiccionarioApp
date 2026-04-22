//
//  OpenAPIViewModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-04-11.
//

import Foundation
import ChatGPTSwift
import Combine
import SwiftUI

@MainActor
class ViewModel: NSObject, ObservableObject {
    var openAI: ChatGPTAPI!
    @AppStorage("apiKey") var apiKey: String = "" {
        didSet {
            if apiKey.isEmpty {
                openAI = nil
                print("openAI = nil")
            } else {
                openAI = ChatGPTAPI(apiKey: apiKey)
                print("openAI = ChatGPTAPI(apiKey: apiKey)")
            }
        }
    }

    @Published var chatResponse: [String] = []
    @Published var prompt: String = ""
    @Published var messages: [String] = []
    @Published var isLoading: Bool = false

    let errorMessage = "\nPlease check API key and network."

    // MARK: - Request Open API

    func tryChatGPT(wordSelected: String) {
        Task {
            do {
                guard let openAI = openAI else {
                    chatResponse.append(errorMessage)
                    return
                }
                let response = try await openAI.sendMessage(text: "give a bullet list with 2 synonym of \(wordSelected) in swedish and write 1 example ho to use it")
                chatResponse.append(response)
            } catch {
                chatResponse.append(error.localizedDescription)
            }
        }
    }

    override init() {
        super.init()
        self.openAI = .init(apiKey: apiKey)
    }
}
