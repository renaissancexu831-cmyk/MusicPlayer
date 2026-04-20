//
//  Song.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//

// MARK: - Song.swift
import Foundation

struct Song: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artist: Artist
    let album: Album?
    let duration: TimeInterval // in seconds
    let artworkURL: URL?
    let previewURL: URL? // streaming URL
    let releaseDate: Date?
    var isFavorite: Bool = false

    var durationText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Album.swift
struct Album: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let artistName: String
    let artworkURL: URL?
    let releaseDate: Date?
    let songs: [Song]?
}

// MARK: - Artist.swift
struct Artist: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageURL: URL?
    let genres: [String]?
}

// MARK: - Playlist.swift
struct Playlist: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var description: String?
    var artworkURL: URL?
    var songs: [Song]
    let createdAt: Date
    var isUserCreated: Bool = true
}
