import SwiftUI
import Combine

class JuegoViewModel: ObservableObject {
    @Published var preguntaActual: Pregunta = .placeholder
    @Published var estrellas = 0
    @Published var nivelDificultad = 1
    @Published var preguntasRespondidas = 0
    @Published var edadSeleccionada: Int = 6
    @Published var dificultadFija = false
    @Published var puntosIA = 0
    @Published var rondaActual = 1
    @Published var totalRondas = 5
    @Published var juegoTerminado = false
    @Published var mensajeErrorCarga: String?

    private var todasLasPreguntas: [Pregunta] = []
    private var preguntasUsadas: Set<Int> = []

    init() {
        cargarPreguntas()
    }

    func cargarPreguntas() {
        do {
            todasLasPreguntas = try PreguntasLocalDataSource.cargarDesdeBundle()
            mensajeErrorCarga = nil
        } catch {
            do {
                todasLasPreguntas = try PreguntasLocalDataSource.cargarDesdeStringLocal()
                mensajeErrorCarga = nil
            } catch {
                todasLasPreguntas = [.placeholder]
                mensajeErrorCarga = error.localizedDescription
            }
        }

        preguntaActual = todasLasPreguntas.first ?? .placeholder
    }

    func configurarJuego(
        edad: Int,
        dificultadInicial: Int? = nil,
        dificultadFija: Bool = false,
        modo: GameMode = .clasico,
        totalRondas: Int = 5
    ) {
        if todasLasPreguntas.isEmpty {
            cargarPreguntas()
        }

        self.edadSeleccionada = edad
        self.dificultadFija = dificultadFija
        self.totalRondas = max(1, totalRondas)
        self.estrellas = 0
        self.puntosIA = 0
        self.preguntasRespondidas = 0
        self.rondaActual = 1
        self.juegoTerminado = false
        self.preguntasUsadas.removeAll()

        if let dificultadInicial {
            self.nivelDificultad = max(1, min(3, dificultadInicial))
        } else {
            self.nivelDificultad = dificultadRecomendada(para: edad)
        }

        seleccionarSiguientePregunta()
    }

    func procesarRespuesta(fueCorrecta: Bool) {
        guard !juegoTerminado else { return }

        preguntasRespondidas += 1

        if fueCorrecta {
            estrellas += 10
        } else {
            estrellas = max(0, estrellas - 5)
        }

        ajustarDificultad(segun: fueCorrecta)

        if preguntasRespondidas >= totalRondas {
            juegoTerminado = true
            return
        }

        seleccionarSiguientePregunta()
    }

    func siguientePregunta() {
        guard !juegoTerminado else { return }
        seleccionarSiguientePregunta()
    }

    func registrarRespuestaVsIA(_ seleccion: String) -> ResultadoRondaIA {
        let jugadorAcerto = seleccion == preguntaActual.respuestaCorrecta
        let aciertoIA = Double.random(in: 0...1) < probabilidadAciertoIA()
        let puntosJugadorGanados = jugadorAcerto ? 10 : 0
        let puntosIAGanados = aciertoIA ? 10 : 0

        estrellas += puntosJugadorGanados
        puntosIA += puntosIAGanados
        preguntasRespondidas += 1

        ajustarDificultad(segun: jugadorAcerto)

        let termino = preguntasRespondidas >= totalRondas
        juegoTerminado = termino

        if !termino {
            rondaActual += 1
            seleccionarSiguientePregunta()
        }

        return ResultadoRondaIA(
            jugadorAcerto: jugadorAcerto,
            iaAcerto: aciertoIA,
            puntosJugadorGanados: puntosJugadorGanados,
            puntosIAGanados: puntosIAGanados,
            siguienteDificultad: nivelDificultad,
            juegoTerminado: termino
        )
    }

    private func ajustarDificultad(segun respuestaCorrecta: Bool) {
        guard !dificultadFija else { return }

        if respuestaCorrecta {
            nivelDificultad = min(3, nivelDificultad + 1)
        } else {
            nivelDificultad = max(1, nivelDificultad - 1)
        }
    }

    private func probabilidadAciertoIA() -> Double {
        switch nivelDificultad {
        case 1:
            return 0.45
        case 2:
            return 0.65
        default:
            return 0.82
        }
    }

    private func dificultadRecomendada(para edad: Int) -> Int {
        switch edad {
        case ...8:
            return 1
        case 9...12:
            return 2
        default:
            return 3
        }
    }

    private func seleccionarSiguientePregunta() {
        guard !todasLasPreguntas.isEmpty else {
            preguntaActual = .placeholder
            return
        }

        let candidatasSinUsar = todasLasPreguntas.filter {
            $0.dificultad == nivelDificultad && !preguntasUsadas.contains($0.id)
        }

        if let nuevaPregunta = candidatasSinUsar.randomElement() {
            preguntaActual = nuevaPregunta
            preguntasUsadas.insert(nuevaPregunta.id)
            return
        }

        let candidatasAlternas = todasLasPreguntas
            .filter { !preguntasUsadas.contains($0.id) }
            .sorted { abs($0.dificultad - nivelDificultad) < abs($1.dificultad - nivelDificultad) }

        if let alternativa = candidatasAlternas.first {
            preguntaActual = alternativa
            preguntasUsadas.insert(alternativa.id)
            return
        }

        preguntasUsadas.removeAll()
        preguntaActual = todasLasPreguntas
            .filter { $0.dificultad == nivelDificultad }
            .randomElement() ?? todasLasPreguntas.randomElement() ?? .placeholder
        preguntasUsadas.insert(preguntaActual.id)
    }
}
