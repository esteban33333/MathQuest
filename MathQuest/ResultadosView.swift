import SwiftUI

struct ResultadosView: View {
    let puntos: Int
    var puntosIA: Int? = nil
    var rondasJugadas: Int? = nil
    var rondasTotales: Int? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.96, green: 0.97, blue: 1.0), Color(red: 0.90, green: 0.98, blue: 0.93)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(titulo)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(emojiResultado)
                    .font(.system(size: 92))

                VStack(spacing: 14) {
                    marcador(titulo: "Tus puntos", valor: "\(puntos) ⭐️", color: .blue)

                    if let puntosIA {
                        marcador(titulo: "Puntos de la IA", valor: "\(puntosIA) ⭐️", color: .purple)
                    }

                    if let rondasJugadas, let rondasTotales {
                        marcador(
                            titulo: "Rondas",
                            valor: "\(rondasJugadas)/\(rondasTotales)",
                            color: .green
                        )
                    }

                    if let puntosIA {
                        Text(mensajeResumen)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 10)

                Button("Volver al menú") {
                    dismiss()
                }
                .font(.headline.weight(.black))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.25, green: 0.60, blue: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(24)
        }
    }

    private var titulo: String {
        if let puntosIA {
            if puntos > puntosIA { return "¡GANASTE A LA IA!" }
            if puntos < puntosIA { return "¡LA IA GANÓ!" }
            return "¡EMPATE!"
        } else {
            return puntos > 0 ? "¡FELICIDADES!" : "¡INTÉNTALO DE NUEVO!"
        }
    }

    private var emojiResultado: String {
        if let puntosIA {
            if puntos > puntosIA { return "🏆" }
            if puntos < puntosIA { return "🤖" }
            return "🤝"
        }

        return puntos > 0 ? "⭐️" : "🌟"
    }

    private var mensajeResumen: String {
        guard let puntosIA else { return "" }

        if puntos > puntosIA {
            return "Le ganaste a la IA. ¡Excelente trabajo!"
        } else if puntos < puntosIA {
            return "La IA te ganó esta vez, pero ya sabes qué practicar."
        } else {
            return "Quedaron empatados. ¡Fue una gran batalla!"
        }
    }

    private func marcador(titulo: String, valor: String, color: Color) -> some View {
        HStack {
            Text(titulo)
                .font(.headline.weight(.bold))
            Spacer()
            Text(valor)
                .font(.title3.weight(.black))
                .foregroundColor(color)
        }
    }
}
