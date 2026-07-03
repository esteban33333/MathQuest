import Foundation

// Esta estructura debe coincidir al 100% con los mapeos de tu BatallaIAViewModel
struct RespuestaGroq: Codable {
    let pregunta: String
    let opciones: [String]
    let correcta: String
    let mensajeDivertido: String
}

final class GroqService {
    static let shared = GroqService()
    private init() {}
    
    // ⚠️ SEGURIDAD: Nunca compartas esta clave en repositorios públicos (GitHub)
    private let apiKey = "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"
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions"
    
    func generarPreguntaIA(edad: Int, nivelDificultad: Int, racha: Int, completion: @escaping (RespuestaGroq?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        
        // Guías de contenido mejoradas para mayor dificultad
        var guiaMatematica = ""
        switch nivelDificultad {
        case 1:
            guiaMatematica = "Genera una suma o resta simple con números de una o dos cifras ideales para un niño de \(edad) años."
        case 2:
            guiaMatematica = "Genera multiplicaciones, divisiones sencillas, fracciones básicas o áreas de figuras geométricas simples."
        default:
            guiaMatematica = "Genera problemas de ÁLGEBRA (despejar X en ecuaciones de 1er grado), TRIGONOMETRÍA (seno, coseno, tangente o Teorema de Pitágoras) o GEOMETRÍA avanzada. ¡Haz que el usuario piense!"
        }
        
        let promptSistema = """
        Eres el motor matemático de IA para el videojuego MathQuest. Tu misión es fabricar un problema dinámico en vivo para un estudiante de \(edad) años.
        Dificultad actual: Nivel \(nivelDificultad). Racha de aciertos del jugador: \(racha).
        
        REGLA MATEMÁTICA OBLIGATORIA: \(guiaMatematica)
        
        Debes formular una interacción corta, lúdica y competitiva de la IA hacia el niño (Ej: '¡Vaya racha! A ver si puedes con esta ecuación de álgebra' o '¡Casi me vences! Resuelve esto').
        
        Devuelve EXCLUSIVAMENTE un JSON plano bien estructurado. Está estrictamente prohibido usar markdown, texto aclaratorio o bloques ```json.
        {
          "pregunta": "Escribe aquí la operación matemática, ecuación o problema",
          "opciones": ["OpciónA", "OpciónB", "OpciónC", "OpciónD"],
          "correcta": "Escribe la respuesta correcta (Debe ser idéntica a una de las 4 opciones)",
          "mensajeDivertido": "Escribe aquí el comentario competitivo de la IA"
        }
        """
        
        let cuerpo: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [["role": "system", "content": promptSistema]],
            "temperature": 0.6,
            "response_format": ["type": "json_object"]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: cuerpo)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let contentString = message["content"] as? String,
                   let contentData = contentString.data(using: .utf8) {
                    
                    let objetoGenerado = try JSONDecoder().decode(RespuestaGroq.self, from: contentData)
                    DispatchQueue.main.async {
                        completion(objetoGenerado)
                    }
                } else {
                    DispatchQueue.main.async { completion(nil) }
                }
            } catch {
                print("❌ Error decodificando IA: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
