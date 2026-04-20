//
//  LibraryView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//

import SwiftUI


// MARK: - LibraryView.swift
struct LibraryView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @EnvironmentObject var playerService: AudioPlayerService
    @State private var selectedTab = 0
    @State private var showCreatePlaylist = false
    @State private var newPlaylistName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Picker
                Picker("", selection: $selectedTab) {
                    Text("Playlists").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        if selectedTab == 0 {
                            playlistsSection
                        } else {
                            favoritesSection
                        }
                        Spacer().frame(height: 120)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Your Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreatePlaylist = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .alert("New Playlist", isPresented: $showCreatePlaylist) {
                TextField("Playlist name", text: $newPlaylistName)
                Button("Create") {
                    if !newPlaylistName.isEmpty {
                        libraryVM.createPlaylist(name: newPlaylistName)
                        newPlaylistName = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newPlaylistName = ""
                }
            }
        }
    }

    private var playlistsSection: some View {
        Group {
            if libraryVM.userPlaylists.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No playlists yet")
                        .foregroundColor(.gray)
                    Text("Tap + to create one")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(libraryVM.userPlaylists) { playlist in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.6), .blue.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "music.note.list")
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            Text(playlist.name)
                                .font(.body)
                                .foregroundColor(.white)
                            Text("\(playlist.songs.count) songs")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private var favoritesSection: some View {
        Group {
            if libraryVM.favoriteSongs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                    Text("Tap ♡ on any song to save it here")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(libraryVM.favoriteSongs) { song in
                    SongRowView(song: song) {
                        playerService.play(
                            song: song,
                            in: libraryVM.favoriteSongs
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
