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

class PostViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            fatalError("Invalid URL")
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("Invalid response")
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                DispatchQueue.main.async {
                    self.posts = posts
                }
            } catch {
                print("Error decoding posts: \(error.localizedDescription)")
            }
        }.resume()
    }
}


