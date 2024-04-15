//
//  AudioPlayerView.swift
//  MusicPlayer
//
//  Created by Chase Kellogg on 4/4/24.
//

import Foundation

import SwiftUI
import AVFoundation
import Combine

class TimeObserver: ObservableObject {
    var token: Any?

//    func updateTimeObserverToken(newToken: Any?) {
//        self.token = newToken
//    }
    
    weak var player: AVPlayer? // Keep a weak reference to the player

    deinit {
        // Ensure to remove the observer when the instance is deinitialized
        if let token = token {
            player?.removeTimeObserver(token)
        }
    }

    func updateTimeObserverToken(newToken: Any?, forPlayer newPlayer: AVPlayer) {
        if let token = token {
            player?.removeTimeObserver(token) // Remove existing observer
        }
        token = newToken
        player = newPlayer
    }
}

struct AudioPlayerView: View {
    @Binding var player: AVPlayer?
    @Binding var isPlaying: Bool
    @Binding var progress: Double
    @StateObject private var timeObserver = TimeObserver()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.isPlaying.toggle()
                    if self.isPlaying {
                        self.player?.play()
                    } else {
                        self.player?.pause()
                    }
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }

                Slider(value: $progress, in: 0...1, onEditingChanged: { editing in
                    guard let duration = self.player?.currentItem?.duration, duration.isNumeric, CMTimeGetSeconds(duration) > 0 else { return }
                    let totalSeconds = CMTimeGetSeconds(duration) / 2
                    //print(totalSeconds)
                    let value = totalSeconds * self.progress
                    let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
                    self.player?.seek(to: seekTime)
                })

                Text("\(formatTime(for: progress))")
            }
            .padding()
        }
        .onChange(of: player) {
            updatePlayerObserver()
        }
        .onAppear {
            updatePlayerObserver()
        }
    }
    
    func updatePlayerObserver() {
        if let token = timeObserver.token {
            player?.removeTimeObserver(token)
        }
        setupPlayer()
    }

    func setupPlayer() {
        guard let player = player else { return }
        let interval = CMTimeMakeWithSeconds(0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
//        if let token = timeObserver.token {
//            player.removeTimeObserver(token)
//        }
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            guard let currentItem = self.player?.currentItem else { return }
            if CMTimeGetSeconds(time) >= (CMTimeGetSeconds(currentItem.duration) / 2) {
                self.player?.pause()
                self.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
                self.isPlaying = false
            } else {
                self.updateProgress(for: currentItem, with: time)
            }
        }
        //timeObserver.updateTimeObserverToken(newToken: newToken, forPlayer: player)
        
//        timeObserver.updateTimeObserverToken(newToken: player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
//            guard let currentItem = self.player?.currentItem else { return }
//            if CMTimeGetSeconds(time) >= (CMTimeGetSeconds(currentItem.duration) / 2) {
//                self.player?.pause()
//                self.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
//                self.isPlaying = false
//            } else {
//                self.updateProgress(for: currentItem, with: time)
//            }
//        })
        
    }

    func updateProgress(for currentItem: AVPlayerItem, with currentTime: CMTime) {
        let duration = currentItem.duration
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let totalSeconds = CMTimeGetSeconds(duration) / 2
        progress = totalSeconds == 0 ? 0 : currentSeconds / totalSeconds
    }

    func formatTime(for progress: Double) -> String {
        // Convert progress to time strings
        // ...
        guard let currentItem = player?.currentItem else { return "00:00" }
        let duration = currentItem.duration

        if duration.timescale == 0 {
            // Avoid division by zero
            return "00:00"
        }

        let totalDurationSeconds = CMTimeGetSeconds(duration) / 2
        if totalDurationSeconds.isNaN || totalDurationSeconds.isInfinite {
            // Handling NaN or Infinite duration
            return "00:00"
        }

        let currentSeconds = totalDurationSeconds * progress
        let minutes = Int(currentSeconds) / 60
        let seconds = Int(currentSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
