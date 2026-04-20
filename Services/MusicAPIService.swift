//
//  MusicAPIService.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


// MARK: - MusicAPIService.swift
import Foundation

actor MusicAPIService {

    static let shared = MusicAPIService()
    private let baseURL = "https://api.example-music.com/v1" // Replace with real API

    // MARK: - Fetch Featured Playlists
    func fetchFeaturedPlaylists() async throws -> [Playlist] {
        // In production, this would be a real API call.
        // Returning mock data for demonstration:
        return await MockData.featuredPlaylists
    }

    // MARK: - Fetch Recently Played
    func fetchRecentlyPlayed() async throws -> [Song] {
        return await MockData.recentlyPlayed
    }

    // MARK: - Search
    func search(query: String) async throws -> [Song] {
        guard !query.isEmpty else { return [] }
        // Simulated network delay
        try await Task.sleep(for: .milliseconds(300))
        return await MockData.allSongs.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.name.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Fetch Top Charts
    func fetchTopCharts() async throws -> [Song] {
        return await MockData.topCharts
    }
}

// MARK: - Mock Data
struct MockData {

    static let artists: [Artist] = [
        Artist(id: "a1", name: "Luna Ray", imageURL: nil, genres: ["Pop", "Electronic"]),
        Artist(id: "a2", name: "The Midnight", imageURL: nil, genres: ["Synthwave"]),
        Artist(id: "a3", name: "Jade Phoenix", imageURL: nil, genres: ["R&B", "Soul"]),
        Artist(id: "a4", name: "Echo Valley", imageURL: nil, genres: ["Indie Rock"]),
        Artist(id: "a5", name: "Neon Drift", imageURL: nil, genres: ["Electronic"]),
    ]

    static let allSongs: [Song] = [
        Song(id: "s1", title: "Midnight Drive", artist: artists[1],
             album: nil, duration: 234,
             artworkURL: URL(string: "https://picsum.photos/seed/song1/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
             releaseDate: nil),
        Song(id: "s2", title: "Starlight", artist: artists[0],
             album: nil, duration: 198,
             artworkURL: URL(string: "https://picsum.photos/seed/song2/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"),
             releaseDate: nil),
        Song(id: "s3", title: "Golden Hour", artist: artists[2],
             album: nil, duration: 267,
             artworkURL: URL(string: "https://picsum.photos/seed/song3/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"),
             releaseDate: nil),
        Song(id: "s4", title: "Electric Dreams", artist: artists[4],
             album: nil, duration: 312,
             artworkURL: URL(string: "https://picsum.photos/seed/song4/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"),
             releaseDate: nil),
        Song(id: "s5", title: "Wanderlust", artist: artists[3],
             album: nil, duration: 245,
             artworkURL: URL(string: "https://picsum.photos/seed/song5/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"),
             releaseDate: nil),
        Song(id: "s6", title: "Neon Lights", artist: artists[4],
             album: nil, duration: 289,
             artworkURL: URL(string: "https://picsum.photos/seed/song6/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3"),
             releaseDate: nil),
        Song(id: "s7", title: "Ocean Waves", artist: artists[0],
             album: nil, duration: 210,
             artworkURL: URL(string: "https://picsum.photos/seed/song7/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3"),
             releaseDate: nil),
        Song(id: "s8", title: "Velvet Sky", artist: artists[2],
             album: nil, duration: 276,
             artworkURL: URL(string: "https://picsum.photos/seed/song8/400"),
             previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3"),
             releaseDate: nil),
    ]

    static let topCharts = Array(allSongs.prefix(5))
    static let recentlyPlayed = Array(allSongs.suffix(4))

    static let featuredPlaylists: [Playlist] = [
        Playlist(id: "p1", name: "Today's Top Hits",
                 description: "The hottest tracks right now",
                 artworkURL: URL(string: "https://picsum.photos/seed/playlist1/400"),
                 songs: Array(allSongs.prefix(4)), createdAt: .now, isUserCreated: false),
        Playlist(id: "p2", name: "Chill Vibes",
                 description: "Relax and unwind",
                 artworkURL: URL(string: "https://picsum.photos/seed/playlist2/400"),
                 songs: Array(allSongs.suffix(4)), createdAt: .now, isUserCreated: false),
        Playlist(id: "p3", name: "Late Night Synthwave",
                 description: "Retro electronic beats",
                 artworkURL: URL(string: "https://picsum.photos/seed/playlist3/400"),
                 songs: allSongs.shuffled(), createdAt: .now, isUserCreated: false),
        Playlist(id: "p4", name: "Indie Discoveries",
                 description: "Fresh indie tracks",
                 artworkURL: URL(string: "https://picsum.photos/seed/playlist4/400"),
                 songs: Array(allSongs[2...5]), createdAt: .now, isUserCreated: false),
    ]
}

