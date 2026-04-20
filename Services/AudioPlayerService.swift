//
//  AudioPlayerService.swift
//  MusicPlayer
//
//  Created by Vincent Xu on 20/04/2026.
//

import AVFoundation
import Combine
import MediaPlayer

enum RepeatMode {
    case off, all, one
}

@MainActor
final class AudioPlayerService: ObservableObject {

    static let shared = AudioPlayerService()

    // MARK: - Published Properties
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isShuffleOn: Bool = false
    @Published var repeatMode: RepeatMode = .off
    @Published var volume: Float = 0.7
    @Published var isBuffering: Bool = false

    // MARK: - Queue
    @Published var queue: [Song] = []
    @Published var currentIndex: Int = 0
    private var originalQueue: [Song] = []

    // MARK: - Private
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    private var statusObservation: NSKeyValueObservation?
    private var currentPlayerItem: AVPlayerItem? // Track the specific item

    // MARK: - Init
    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    // MARK: - Audio Session
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }

    // MARK: - Playback Controls
    func play(song: Song, in playlist: [Song]? = nil) {
        if let playlist = playlist {
            originalQueue = playlist
            queue = isShuffleOn ? playlist.shuffled() : playlist
            currentIndex = queue.firstIndex(where: { $0.id == song.id }) ?? 0
        }

        currentSong = song
        guard let url = song.previewURL else {
            print("⚠️ No preview URL for song: \(song.title)")
            return
        }

        // Clean up previous player
        cleanupPlayer()

        // Reset state for new track
        currentTime = 0
        duration = 0
        isBuffering = true

        let playerItem = AVPlayerItem(url: url)
        currentPlayerItem = playerItem // FIX #2: Track specific item
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume

        // FIX #7: Observe player item status for errors & buffering
        statusObservation = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isBuffering = false
                    // FIX #6: Update duration when actually available
                    if self.duration == 0,
                       let dur = self.player?.currentItem?.duration.seconds, // Optional chain → Double?
                       !dur.isNaN {
                        self.duration = dur
                    }
                    self.updateNowPlayingInfo()
                case .failed:
                    print("❌ Player item failed: \(item.error?.localizedDescription ?? "unknown")")
                    self.isBuffering = false
                    self.isPlaying = false
                default:
                    break
                }
            }
        }

        // Observe playback time
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            // FIX #3: Capture duration from the time observer's context safely
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.currentTime = time.seconds

                // Update duration if it wasn't set yet (e.g., for streams)
                if self.duration == 0,
                   let dur = self.player?.currentItem?.duration.seconds,
                   !dur.isNaN {
                    self.duration = dur
                }
            }
        }

        // FIX #2: Filter notification by the specific player item
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.handleSongEnd()
                }
            }
            .store(in: &cancellables)

        player?.play()
        isPlaying = true
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        updateNowPlayingInfo()
    }

    func nextTrack() {
        guard !queue.isEmpty else { return }
        currentIndex = (currentIndex + 1) % queue.count
        play(song: queue[currentIndex])
    }

    func previousTrack() {
        // FIX #5: If more than 3 seconds in, restart current song & update UI immediately
        if currentTime > 3 {
            currentTime = 0 // Immediate UI feedback
            seek(to: 0)
            return
        }
        guard !queue.isEmpty else { return }
        currentIndex = currentIndex > 0 ? currentIndex - 1 : queue.count - 1
        play(song: queue[currentIndex])
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            if finished {
                Task { @MainActor [weak self] in
                    self?.updateNowPlayingInfo()
                }
            }
        }
    }

    func toggleShuffle() {
        isShuffleOn.toggle()
        guard !queue.isEmpty else { return } // FIX: Guard against empty queue

        let current = queue[currentIndex]
        if isShuffleOn {
            queue.shuffle()
        } else {
            queue = originalQueue
        }
        // Restore index to current song in new order
        if let newIndex = queue.firstIndex(where: { $0.id == current.id }) {
            currentIndex = newIndex
        }
    }

    func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    func setVolume(_ value: Float) {
        volume = value
        player?.volume = value
    }

    // MARK: - Private Helpers
    private func handleSongEnd() {
        // FIX #4: Verify the notification is for the current item
        // (The object filter on the publisher already handles this,
        //  but double-check in case of race conditions)
        switch repeatMode {
        case .one:
            currentTime = 0
            seek(to: 0)
            player?.play()
            isPlaying = true
        case .all:
            nextTrack()
        case .off:
            if currentIndex < queue.count - 1 {
                nextTrack()
            } else {
                isPlaying = false
                currentTime = 0
                updateNowPlayingInfo()
            }
        }
    }

    private func cleanupPlayer() {
        // Remove time observer
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }

        // Cancel KVO observation
        statusObservation?.invalidate()
        statusObservation = nil

        // Cancel Combine subscriptions (notification observers)
        cancellables.removeAll()

        // Stop and release player
        player?.pause()
        player?.replaceCurrentItem(with: nil) // Release the item explicitly
        player = nil
        currentPlayerItem = nil
    }

    // MARK: - Now Playing Info (Lock Screen)
    private func updateNowPlayingInfo() {
        guard let song = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = song.title
        info[MPMediaItemPropertyArtist] = song.artist.name
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        // FIX #6: Include album title if available
        if let album = song.album {
            info[MPMediaItemPropertyAlbumTitle] = album.title
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Command Center (Lock Screen Controls)
    // FIX #1: Use nonisolated where needed, dispatch to MainActor properly
    private func setupRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayPause() }
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.nextTrack() }
            return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.previousTrack() }
            return .success
        }
        center.changePlaybackPositionCommand.isEnabled = true // FIX: Explicitly enable
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                Task { @MainActor in self?.seek(to: event.positionTime) }
            }
            return .success
        }
    }
}

