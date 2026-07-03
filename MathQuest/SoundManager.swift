import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    var effectPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?

    // Para sonidos cortos (Efectos)
    func playSound(named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "mp3") else {
            print("❌ No encontré el archivo: \(named).mp3")
            return
        }
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.play()
        } catch {
            print("❌ Error al reproducir el efecto: \(error)")
        }
    }

    // Para música de fondo (Loop infinito)
    func playBackgroundMusic(named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "mp3") else { return }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Esto hace que se repita siempre
            musicPlayer?.volume = 0.4       // Volumen suave para música de fondo
            musicPlayer?.play()
        } catch {
            print("❌ Error al reproducir la música: \(error)")
        }
    }
}
