//
//  AudioPlaybackView.swift
//  DiccionarioApp
//
//  Created by Alvar Arias on 2023-03-25.
//

import SwiftUI

struct AudioPlaybackView: View {
    @State private var isPlaying: Bool = false
    let player: PlayerWord
    let phonetic: Phonetic?

    var body: some View {
        HStack {
            Text(phonetic?.content ?? "Not file")
            Spacer(minLength: 10)

            Button {
                player.togglePlayingState(url: phonetic?.file ?? "Not file")
            } label: {
                Image(systemName: player.player.timeControlStatus == .playing ? "pause.fill" : "play.fill")
            }
            .foregroundColor(Color.orange)
            .onReceive(NotificationCenter.default.publisher(for: .playerStopped)) { _ in
                isPlaying = false
            }
        }
        .listRowSeparator(.hidden)
    }
}

