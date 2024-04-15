//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Chase Kellogg on 4/2/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer


@main
struct MusicPlayerApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
//    private func setupAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to set up audio session for background playback: \(error)")
//        }
//    }
//    
//    private func setupRemoteTransportControls() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//        
//        commandCenter.playCommand.addTarget { [unowned self] event in
//            if player.rate == 0.0 {
//                player.play()
//                updateNowPlayingInfo()
//                return .success
//            }
//            return .commandFailed
//        }
//        
//        commandCenter.pauseCommand.addTarget { [unowned self] event in
//            if player.rate == 1.0 {
//                player.pause()
//                updateNowPlayingInfo()
//                return .success
//            }
//            return .commandFailed
//        }
//        
//        // Add other commands as needed...
//    }
//
//    private func updateNowPlayingInfo() {
//        var nowPlayingInfo = [String: Any]()
//        nowPlayingInfo[MPMediaItemPropertyTitle] = "Song Title" // Update with actual song title
//        nowPlayingInfo[MPMediaItemPropertyArtist] = "Artist Name" // Update with actual artist
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
}
