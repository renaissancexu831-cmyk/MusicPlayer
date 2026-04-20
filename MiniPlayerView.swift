//
//  MiniPlayerView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//

import SwiftUI

// MARK: - MiniPlayerView.swift
struct MiniPlayerView: View {
    @Binding var showFullPlayer: Bool
    @EnvironmentObject var playerService: AudioPlayerService

    var body: some View {
        if let song = playerService.currentSong {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                        Rectangle()
                            .fill(Color.green)
                            .frame(
                                width: playerService.duration > 0
                                    ? geo.size.width * (playerService.currentTime / playerService.duration)
                                    : 0
                            )
                    }
                }
                .frame(height: 2)

                HStack(spacing: 12) {
                    // Artwork
                    AsyncImage(url: song.artworkURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "music.note")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Song Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(song.artist.name)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Controls
                    Button { playerService.togglePlayPause() } label: {
                        Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Button { playerService.nextTrack() } label: {
                        Image(systemName: "forward.fill")
                            .font(.body)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .onTapGesture {
                showFullPlayer = true
            }
        }
    }
}
