import Foundation

enum GameMode {
    case clasico
    case vsIA
}

enum Dificultad: Int, CaseIterable, Identifiable {
    case facil = 1
    case media = 2
    case dificil = 3

    var id: Int { rawValue }

    var titulo: String {
        switch self {
        case .facil: return "Fácil"
        case .media: return "Medio"
        case .dificil: return "Difícil"
        }
    }

    var descripcion: String {
        switch self {
        case .facil: return "Sumas y restas básicas"
        case .media: return "Multiplicación, división y área"
        case .dificil: return "Álgebra y porcentajes"
        }
    }
}

struct Nivel: Identifiable {
    let id = UUID()
    let numero: Int
    let dificultad: Dificultad
    let nombre: String
}

struct PerfilUsuario: Codable, Equatable {
    let nombre: String
    let edad: Int
    let esInvitado: Bool

    static let invitado = PerfilUsuario(
        nombre: "Invitado",
        edad: 8,
        esInvitado: true
    )
}

struct ResultadoRondaIA {
    let jugadorAcerto: Bool
    let iaAcerto: Bool
    let puntosJugadorGanados: Int
    let puntosIAGanados: Int
    let siguienteDificultad: Int
    let juegoTerminado: Bool
}

let niveles: [Nivel] = [
    Nivel(numero: 1, dificultad: .facil, nombre: "Calentamiento"),
    Nivel(numero: 2, dificultad: .facil, nombre: "Explorador"),
    Nivel(numero: 3, dificultad: .facil, nombre: "Velocidad"),
    Nivel(numero: 4, dificultad: .media, nombre: "Estratega"),
    Nivel(numero: 5, dificultad: .media, nombre: "Multiplica"),
    Nivel(numero: 6, dificultad: .media, nombre: "Geometría"),
    Nivel(numero: 7, dificultad: .dificil, nombre: "Álgebra"),
    Nivel(numero: 8, dificultad: .dificil, nombre: "Desafío"),
    Nivel(numero: 9, dificultad: .dificil, nombre: "Leyenda")
]
