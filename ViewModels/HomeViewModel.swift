//
//  HomeViewModel.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//



import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featuredPlaylists: [Playlist] = []
    @Published var recentlyPlayed: [Song] = []
    @Published var topCharts: [Song] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = MusicAPIService.shared

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let playlists = api.fetchFeaturedPlaylists()
            async let recent = api.fetchRecentlyPlayed()
            async let charts = api.fetchTopCharts()

            featuredPlaylists = try await playlists
            recentlyPlayed = try await recent
            topCharts = try await charts
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

// MARK: - SearchViewModel.swift
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Song] = []
    @Published var isSearching = false

    private let api = MusicAPIService.shared
    private var searchTask: Task<Void, Never>?

    func search() {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        isSearching = true
        searchTask = Task {
            do {
                // Debounce
                try await Task.sleep(for: .milliseconds(400))
                let searchResults = try await api.search(query: query)
                if !Task.isCancelled {
                    results = searchResults
                }
            } catch {
                if !Task.isCancelled {
                    results = []
                }
            }
            isSearching = false
        }
    }
}


// MARK: - LibraryViewModel.swift
@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var favoriteSongs: [Song] = []
    @Published var userPlaylists: [Playlist] = []

    func toggleFavorite(_ song: Song) {
        if let index = favoriteSongs.firstIndex(where: { $0.id == song.id }) {
            favoriteSongs.remove(at: index)
        } else {
            favoriteSongs.append(song)
        }
    }

    func isFavorite(_ song: Song) -> Bool {
        favoriteSongs.contains(where: { $0.id == song.id })
    }

    func createPlaylist(name: String) {
        let playlist = Playlist(
            id: UUID().uuidString,
            name: name,
            songs: [],
            createdAt: .now
        )
        userPlaylists.append(playlist)
    }

    func addSong(_ song: Song, to playlistId: String) {
        if let index = userPlaylists.firstIndex(where: { $0.id == playlistId }) {
            userPlaylists[index].songs.append(song)
        }
    }
}

