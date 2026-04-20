//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//

import SwiftUI


@main
struct MusicPlayerApp: App {
    @StateObject private var playerService = AudioPlayerService.shared
    @StateObject private var libraryVM = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(playerService)
                .environmentObject(libraryVM)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - MainTabView.swift
struct MainTabView: View {
    @EnvironmentObject var playerService: AudioPlayerService
    @State private var showFullPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
            }
            .accentColor(.green)

            // Mini Player (shown above tab bar)
            if playerService.currentSong != nil {
                VStack(spacing: 0) {
                    MiniPlayerView(showFullPlayer: $showFullPlayer)
                    Spacer().frame(height: 49) // Tab bar height
                }
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            FullPlayerView(isPresented: $showFullPlayer)
                .environmentObject(playerService)
        }
    }
}
