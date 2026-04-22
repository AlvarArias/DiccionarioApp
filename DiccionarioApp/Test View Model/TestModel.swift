//
//  WordModel.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//

import Foundation


// Test View Model

struct Post: Identifiable, Codable {
    let id: Int
    let title: String
    let body: String
}

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts = [Post]()

    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            fatalError("Invalid URL")
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    return
                }
                posts = try JSONDecoder().decode([Post].self, from: data)
            } catch {
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }
}


