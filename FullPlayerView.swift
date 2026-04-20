//
//  FullPlayerView.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//


import SwiftUI


// MARK: - FullPlayerView.swift
struct FullPlayerView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var playerService: AudioPlayerService
    @EnvironmentObject var libraryVM: LibraryViewModel
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.2, blue: 0.35),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // MARK: - Drag Handle & Close
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("Now Playing")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .tracking(1.5)
                    Spacer()
                    Menu {
                        Button("Add to Playlist", systemImage: "plus.circle") {}
                        Button("Share", systemImage: "square.and.arrow.up") {}
                        Button("View Artist", systemImage: "person.circle") {}
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // MARK: - Album Artwork
                if let song = playerService.currentSong {
                    AsyncImage(url: song.artworkURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.5), .blue.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.5))
                                )
                        }
                    }
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 20)
                    .scaleEffect(playerService.isPlaying ? 1.0 : 0.92)
                    .animation(.easeInOut(duration: 0.4), value: playerService.isPlaying)

                    Spacer()

                    // MARK: - Song Info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(song.artist.name)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                        Spacer()

                        Button {
                            libraryVM.toggleFavorite(song)
                        } label: {
                            Image(systemName: libraryVM.isFavorite(song) ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(libraryVM.isFavorite(song) ? .green : .white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Progress Slider
                    VStack(spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { playerService.currentTime },
                                set: { playerService.seek(to: $0) }
                            ),
                            in: 0...max(playerService.duration, 1)
                        )
                        .accentColor(.white)

                        HStack {
                            Text(formatTime(playerService.currentTime))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text(formatTime(playerService.duration))
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 28)

                    // MARK: - Playback Controls
                    PlayerControlsView()
                        .padding(.horizontal, 28)

                    // MARK: - Shuffle & Repeat
                    HStack {
                        Button { playerService.toggleShuffle() } label: {
                            Image(systemName: "shuffle")
                                .font(.body)
                                .foregroundColor(
                                    playerService.isShuffleOn ? .green : .white.opacity(0.5)
                                )
                        }

                        Spacer()

                        // Volume
                        HStack(spacing: 8) {
                            Image(systemName: "speaker.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            Slider(
                                value: Binding(
                                    get: { Double(playerService.volume) },
                                    set: { playerService.setVolume(Float($0)) }
                                ),
                                in: 0...1
                            )
                            .accentColor(.white.opacity(0.6))
                            .frame(width: 120)
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Spacer()

                        Button { playerService.cycleRepeatMode() } label: {
                            Image(systemName: repeatIcon)
                                .font(.body)
                                .foregroundColor(
                                    playerService.repeatMode != .off ? .green : .white.opacity(0.5)
                                )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 30)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 150 {
                        isPresented = false
                    }
                    dragOffset = 0
                }
        )
        .offset(y: dragOffset)
        .animation(.interactiveSpring(), value: dragOffset)
    }

    private var repeatIcon: String {
        switch playerService.repeatMode {
        case .off, .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - PlayerControlsView.swift
struct PlayerControlsView: View {
    @EnvironmentObject var playerService: AudioPlayerService

    var body: some View {
        HStack(spacing: 40) {
            // Previous
            Button { playerService.previousTrack() } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }

            // Play/Pause
            Button { playerService.togglePlayPause() } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                    Image(systemName: playerService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }

            // Next
            Button { playerService.nextTrack() } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 8)
    }
}

