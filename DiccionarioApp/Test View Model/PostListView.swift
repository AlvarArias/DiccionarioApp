//
//  TestView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-17.
//


import SwiftUI

struct PostListView: View {
    @ObservedObject var viewModel = PostViewModel()
    
    var body: some View {
        List(viewModel.posts) { post in
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.body)
                    .font(.subheadline)
            }
        }
        .onAppear(perform: viewModel.fetchPosts)
        .navigationBarTitle("Posts")
    }
}

