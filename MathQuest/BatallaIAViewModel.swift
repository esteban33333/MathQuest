import SwiftUI
import Combine
import AVFoundation

class BatallaIAViewModel: ObservableObject {
    // --- Estado del Juego ---
    @Published var preguntaActual: Pregunta = .placeholder
    @Published var estrellas: Int = 0
    @Published var vidas: Int = 3
    @Published var rondasJugadas: Int = 0
    @Published var nivelDificultad: Int = 1
    @Published var recordMaximo: Int = 0
    @Published var edadSeleccionada: Int = 6
    
    // --- Estado de la Interfaz ---
    @Published var juegoTerminado: Bool = false
    @Published var estaComiendo: Bool = false
    @Published var cargandoPregunta: Bool = false
    @Published var mensajeIA: String = "¡Prepárate para el desafío, Campeón!"
    @Published var tiempoRestante: Int = 15
    @Published var mostrarTemporizador: Bool = false
    
    // --- Control Interno ---
    private var timer: Timer?
    private let kRecordKey = "MathQuest_Record_Survival"

    init() {
        self.recordMaximo = UserDefaults.standard.integer(forKey: kRecordKey)
    }

    func configurarJuego(edad: Int) {
        self.edadSeleccionada = edad
        self.estrellas = 0
        self.vidas = 3
        self.rondasJugadas = 0
        self.juegoTerminado = false
        self.nivelDificultad = 1
        self.mostrarTemporizador = false
        obtenerSiguientePreguntaDesdeIA()
    }

    func registrarRespuesta(seleccion: String) {
        detenerTemporizador()
        
        if seleccion == preguntaActual.respuestaCorrecta {
            // Sonido de acierto
            SoundManager.shared.playSound(named: "correct")
            
            estrellas += (10 * nivelDificultad)
            rondasJugadas += 1
            ajustarDificultad()
            obtenerSiguientePreguntaDesdeIA()
        } else {
            // Sonido de error
            SoundManager.shared.playSound(named: "error")
            
            vidas -= 1
            triggerMonsterEat()
            
            if vidas <= 0 {
                SoundManager.shared.playSound(named: "gameover")
                terminarJuego()
            } else {
                obtenerSiguientePreguntaDesdeIA()
            }
        }
    }

    private func triggerMonsterEat() {
        estaComiendo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.estaComiendo = false
        }
    }

    private func ajustarDificultad() {
        if rondasJugadas > 15 { nivelDificultad = 3 }
        else if rondasJugadas > 7 { nivelDificultad = 2 }
        else { nivelDificultad = 1 }
    }

    private func terminarJuego() {
        if rondasJugadas > recordMaximo {
            recordMaximo = rondasJugadas
            UserDefaults.standard.set(recordMaximo, forKey: kRecordKey)
        }
        juegoTerminado = true
    }

    func obtenerSiguientePreguntaDesdeIA() {
        cargandoPregunta = true
        GroqService.shared.generarPreguntaIA(edad: edadSeleccionada, nivelDificultad: nivelDificultad, racha: rondasJugadas) { [weak self] respuesta in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.cargandoPregunta = false
                if let r = respuesta {
                    self.preguntaActual = Pregunta(id: Int.random(in: 1...1000), textoPregunta: r.pregunta, opciones: r.opciones, respuestaCorrecta: r.correcta, dificultad: self.nivelDificultad, categoria: "Survival")
                    self.mensajeIA = r.mensajeDivertido
                }
                self.iniciarTemporizador()
            }
        }
    }

    private func iniciarTemporizador() {
        detenerTemporizador()
        if nivelDificultad > 1 {
            mostrarTemporizador = true
            tiempoRestante = 15
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.tiempoRestante > 0 { self.tiempoRestante -= 1 }
                else { self.vidas -= 1; self.obtenerSiguientePreguntaDesdeIA() }
            }
        } else {
            mostrarTemporizador = false
        }
    }

    func detenerTemporizador() { timer?.invalidate() }
}
