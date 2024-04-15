import SwiftUI
import AVFoundation
import MediaPlayer

struct ContentView: View {
    @State private var searchQuery: String = ""
    @State private var audioStreamURL: String?
    @State private var searchResults: [Video] = []
    @State private var player: AVPlayer?
    @State private var isLoadingAudio = false
    @State private var isPlaying = false
    @State private var progress = 0.0
    @State private var playingArtist: String = ""
    @State private var playingName: String = ""

    var body: some View {
        ZStack {
            VStack {
                TextField("Enter search query", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Search") {
                    let model = Model()
                    model.getVideos(searchQuery: searchQuery) { videos in
                        DispatchQueue.main.async {
                            self.searchResults = videos.map { video in
                                var modifiedVideo = video
                                modifiedVideo.title = video.title.decodingHTMLEntities()
                                return modifiedVideo
                            }
                        }
                    }
                }
                .padding()
                
                List(searchResults, id: \.videoId) { video in
                    VStack(alignment: .center, spacing: 10) {
                        if let url = URL(string: video.thumbnail) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .cornerRadius(8)
                        }
                        
                        Text(video.title)
                            .font(.headline)
                            .multilineTextAlignment(.center) // Center align the title
                        
                        HStack {
                            Text(video.uploader)
                            Spacer()
                            Text(formatDate(video.published))
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity) // Ensure VStack takes full width
                    .onTapGesture {
                        getAudioStreamURL(youtubeLink: "https://www.youtube.com/watch?v=\(video.videoId)")
                        self.playingArtist = video.uploader
                        self.playingName = video.title
                    }
                }
                .padding(.horizontal)
                
                if player != nil {
                    AudioPlayerView(player: $player, isPlaying: $isPlaying, progress: $progress)
                }
            }
            
            if isLoadingAudio {
                ProgressView()
                    .scaleEffect(3, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(Color.blue) // This sets the color of the ProgressView to blue
            }
        }
        .onAppear {
            setupAudioSession()
            setupRemoteTransportControls()
        }
        .onChange(of: isPlaying) {
            updateNowPlayingInfo()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { event in
            self.player?.play()
            self.isPlaying = true
            return .success
        }

        commandCenter.pauseCommand.addTarget { event in
            self.player?.pause()
            self.isPlaying = false
            return .success
        }
        
        // Add other commands as needed...
    }

    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.playingName // Replace with actual song title
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.playingArtist // Replace with actual artist
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds
        
        let duration = (player?.currentItem?.duration.seconds ?? 0) / 2
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func getAudioStreamURL(youtubeLink: String) {
        isLoadingAudio = true  // Start loading
        guard let url = URL(string: "https://musicplayer-d1169b8bdeeb.herokuapp.com/get_audio_link") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["youtube_link": youtubeLink]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(AudioStreamResponse.self, from: data),
                   let audioURL = URL(string: response.audio_stream_url) {
                    DispatchQueue.main.async {
                        if let existingPlayer = self.player {
                            existingPlayer.pause()
                            existingPlayer.replaceCurrentItem(with: nil) // Clears the current item
                        }
                        self.player = AVPlayer(url: audioURL)
                        self.isPlaying = true
                        self.progress = 0.0
                        self.player?.play()
                        self.isLoadingAudio = false  // Stop loading once player starts
                    }
                }
            }
        }.resume()
    }
}

struct YouTubeVideo {
    let title: String
    let url: String
}

struct AudioStreamResponse: Codable {
    let audio_stream_url: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
