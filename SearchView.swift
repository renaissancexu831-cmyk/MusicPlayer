//
//  SearchView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


import SwiftUI


// MARK: - SearchView.swift
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var playerService: AudioPlayerService

    let genres = [
        ("Pop", "music.mic", Color.pink),
        ("Rock", "guitars.fill", Color.red),
        ("Hip-Hop", "headphones", Color.orange),
        ("Electronic", "waveform", Color.cyan),
        ("R&B", "music.note.tv", Color.purple),
        ("Jazz", "pianokeys", Color.yellow),
        ("Classical", "music.quarternote.3", Color.blue),
        ("Indie", "radio", Color.green),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {

                    // Search Results
                    if !viewModel.query.isEmpty {
                        if viewModel.isSearching {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.green)
                                    .padding(.top, 40)
                                Spacer()
                            }
                        } else if viewModel.results.isEmpty {
                            Text("No results found for \"\(viewModel.query)\"")
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(viewModel.results) { song in
                                SongRowView(song: song) {
                                    playerService.play(
                                        song: song,
                                        in: viewModel.results
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Browse Categories
                        Text("Browse All")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(genres, id: \.0) { genre in
                                GenreCard(
                                    name: genre.0,
                                    icon: genre.1,
                                    color: genre.2
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer().frame(height: 120)
                }
            }
            .background(Color.black)
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.query,
                prompt: "Songs, Artists, Albums"
            )
            .onChange(of: viewModel.query) { _, _ in
                viewModel.search()
            }
        }
    }
}

struct GenreCard: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 100)
            .overlay(
                VStack {
                    Image(systemName: icon)
                        .font(.title2)
                    Text(name)
                        .font(.headline.bold())
                }
                .foregroundColor(.white)
            )
    }
}
