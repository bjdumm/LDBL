import Foundation
import AVFoundation

final class ChampionMusicPlayer {
    static let shared = ChampionMusicPlayer()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    func play() {
        if audioPlayer?.isPlaying == true { return }

        guard let url = Bundle.main.url(forResource: "champion", withExtension: "mp3") else {
            print("🎵 champion.mp3 not found in app bundle.")
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0
            player.volume = 1.0
            player.prepareToPlay()
            player.play()
            audioPlayer = player
            print("🎵 Champion music started. Duration: \(player.duration)s")
        } catch {
            print("🎵 Unable to play champion music: \(error.localizedDescription)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        audioPlayer = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("🎵 Unable to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
