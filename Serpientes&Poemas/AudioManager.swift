import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var soundtrackPlayer: AVAudioPlayer?

    private init() {
        guard let url = Bundle.main.url(forResource: "Jungle Trip - Quincas Moreira", withExtension: "mp3") else { return }
        do {
            soundtrackPlayer = try AVAudioPlayer(contentsOf: url)
            soundtrackPlayer?.numberOfLoops = -1 // Loop indefinitely
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }

    func playSoundtrack() {
        if !(soundtrackPlayer?.isPlaying ?? false) { // Only play if not already playing
            soundtrackPlayer?.play()
        }
    }

    func pauseSoundtrack() {
        soundtrackPlayer?.pause()
    }

    func stopSoundtrack() {
        soundtrackPlayer?.stop()
    }

    func isPlaying() -> Bool {
        return soundtrackPlayer?.isPlaying ?? false
    }

    func setVolume(to volume: Float, duration: TimeInterval) {
        guard let player = soundtrackPlayer else { return }
        let steps = 20
        let stepDuration = duration / Double(steps)
        let currentVolume = player.volume
        let volumeStep = (volume - currentVolume) / Float(steps)

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                player.volume = currentVolume + volumeStep * Float(step)
            }
        }
    }
}