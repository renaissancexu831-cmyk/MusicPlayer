//
//  HomeView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var playerService: AudioPlayerService

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 28) {

                    // MARK: - Greeting
                    greetingSection

                    // MARK: - Featured Playlists
                    if !viewModel.featuredPlaylists.isEmpty {
                        sectionHeader("Featured Playlists")
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.featuredPlaylists) { playlist in
                                    FeaturedCardView(playlist: playlist)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Recently Played
                    if !viewModel.recentlyPlayed.isEmpty {
                        sectionHeader("Recently Played")
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.recentlyPlayed) { song in
                                SongRowView(song: song) {
                                    playerService.play(
                                        song: song,
                                        in: viewModel.recentlyPlayed
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Top Charts
                    if !viewModel.topCharts.isEmpty {
                        sectionHeader("Top Charts 🔥")
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.topCharts.enumerated()), id: \.element.id) { index, song in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.title2.bold())
                                        .foregroundColor(.gray)
                                        .frame(width: 30)
                                    SongRowView(song: song) {
                                        playerService.play(
                                            song: song,
                                            in: viewModel.topCharts
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Bottom spacing for mini player
                    Spacer().frame(height: 120)
                }
                .padding(.top)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.15), .black],
                    startPoint: .top, endPoint: .center
                )
            )
            .navigationBarHidden(true)
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Subviews
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greetingText)
                .font(.title.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .foregroundColor(.white)
            .padding(.horizontal)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good Morning ☀️"
        case 12..<17: return "Good Afternoon 🌤"
        case 17..<21: return "Good Evening 🌅"
        default: return "Good Night 🌙"
        }
    }
}

