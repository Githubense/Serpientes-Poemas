import AVFoundation

/// Manages audio playback and speech synthesis for the game.
class AudioManager {
    // MARK: - Singleton Instance
    static let shared = AudioManager() // Shared instance of the AudioManager.

    // MARK: - Properties
    private var soundtrackPlayer: AVAudioPlayer? // Player for the background soundtrack.
    let speechSynthesizer = AVSpeechSynthesizer() // Synthesizer for text-to-speech functionality.

    // MARK: - Initialization
    private init() {
        // Load the soundtrack from the app bundle.
        guard let url = Bundle.main.url(forResource: "Jungle Trip - Quincas Moreira", withExtension: "mp3") else { return }
        do {
            soundtrackPlayer = try AVAudioPlayer(contentsOf: url)
            soundtrackPlayer?.numberOfLoops = -1 // Loop the soundtrack indefinitely.
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }

    // MARK: - Soundtrack Controls

    /// Plays the background soundtrack if it is not already playing.
    func playSoundtrack() {
        if !(soundtrackPlayer?.isPlaying ?? false) {
            soundtrackPlayer?.play()
        }
    }

    /// Pauses the background soundtrack.
    func pauseSoundtrack() {
        soundtrackPlayer?.pause()
    }

    /// Stops the background soundtrack.
    func stopSoundtrack() {
        soundtrackPlayer?.stop()
    }

    /// Checks if the soundtrack is currently playing.
    /// - Returns: `true` if the soundtrack is playing, `false` otherwise.
    func isPlaying() -> Bool {
        return soundtrackPlayer?.isPlaying ?? false
    }

    /// Smoothly adjusts the volume of the soundtrack over a specified duration.
    /// - Parameters:
    ///   - volume: The target volume level (0.0 to 1.0).
    ///   - duration: The duration over which the volume should be adjusted.
    func setVolume(to volume: Float, duration: TimeInterval) {
        guard let player = soundtrackPlayer else { return }
        let steps = 20 // Number of steps for the volume transition.
        let stepDuration = duration / Double(steps) // Duration of each step.
        let currentVolume = player.volume // Current volume level.
        let volumeStep = (volume - currentVolume) / Float(steps) // Volume increment per step.

        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                player.volume = currentVolume + volumeStep * Float(step)
            }
        }
    }

    // MARK: - Speech Controls

    /// Stops any ongoing speech synthesis immediately.
    func stopSpeech() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}