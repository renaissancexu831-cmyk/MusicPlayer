//
//  FeaturedCardView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


import SwiftUI

struct FeaturedCardView: View {
    let playlist: Playlist
    @EnvironmentObject var playerService: AudioPlayerService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Artwork
            AsyncImage(url: playlist.artworkURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                default:
                    placeholderImage.overlay(ProgressView().tint(.white))
                }
            }
            .frame(width: 170, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(playlist.name)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .lineLimit(1)

            Text(playlist.description ?? "")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 170)
        .onTapGesture {
            if let first = playlist.songs.first {
                playerService.play(song: first, in: playlist.songs)
            }
        }
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "music.note.list")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.7))
            )
    }
}

// MARK: - SongRowView.swift
struct SongRowView: View {
    let song: Song
    var onTap: () -> Void

    @EnvironmentObject var libraryVM: LibraryViewModel

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Artwork
                AsyncImage(url: song.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Title & Artist
                VStack(alignment: .leading, spacing: 3) {
                    Text(song.title)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(song.artist.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                // Duration
                Text(song.durationText)
                    .font(.caption)
                    .foregroundColor(.gray)

                // Favorite Button
                Button {
                    libraryVM.toggleFavorite(song)
                } label: {
                    Image(systemName: libraryVM.isFavorite(song) ? "heart.fill" : "heart")
                        .foregroundColor(libraryVM.isFavorite(song) ? .green : .gray)
                        .font(.body)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

