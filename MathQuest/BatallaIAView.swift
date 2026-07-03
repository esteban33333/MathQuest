import SwiftUI

struct BatallaIAView: View {
    @StateObject var viewModel = BatallaIAViewModel()
    let edad: Int
    let dificultad: Int
    @State private var cloudOffset: CGFloat = -150

    var body: some View {
        ZStack {
            // Fondo
            Color(red: 0.4, green: 0.7, blue: 0.3).ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Header (Récord y Vidas)
                HStack {
                    scoreTag(icon: "star.fill", text: "\(viewModel.estrellas)", color: .yellow)
                    Spacer()
                    VStack { Text("Ronda").font(.caption).bold(); Text("\(viewModel.rondasJugadas)").font(.title2).bold() }
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0..<3) { i in
                            Image(systemName: i < viewModel.vidas ? "heart.fill" : "heart")
                                .foregroundColor(.red).scaleEffect(1.2)
                        }
                    }
                }.padding(.top, 50).padding(.horizontal)

                // Monstruo
                MonstruoView(estaComiendo: viewModel.estaComiendo)
                    .scaleEffect(viewModel.estaComiendo ? 1.25 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.estaComiendo)
                    .frame(height: 140)

                // MENSAJE IA (Scrollable y fijo)
                ScrollView {
                    Text(viewModel.mensajeIA)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 100)
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // PREGUNTA (Scrollable para que no se corte)
                ScrollView {
                    Text(viewModel.preguntaActual.textoPregunta)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 140)
                .background(Color.white.cornerRadius(20))
                .padding(.horizontal, 20)

                // Botones
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(viewModel.preguntaActual.opciones, id: \.self) { op in
                        Button(action: { viewModel.registrarRespuesta(seleccion: op) }) {
                            Text(op)
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 4)
                        }
                    }
                }.padding()
                
                Spacer()
            }

            // Game Over Overlay
            if viewModel.juegoTerminado {
                Color.black.opacity(0.9).ignoresSafeArea()
                VStack {
                    Text("¡JUEGO TERMINADO!").font(.largeTitle.bold()).foregroundColor(.white)
                    Button("Volver a jugar") { viewModel.configurarJuego(edad: edad) }
                        .padding().background(Color.blue).foregroundColor(.white).cornerRadius(15)
                }
            }
        }
        .onAppear { viewModel.configurarJuego(edad: edad) }
    }

    func scoreTag(icon: String, text: String, color: Color) -> some View {
        HStack { Image(systemName: icon).foregroundColor(color); Text(text).bold() }
        .padding(8).background(Color.white.cornerRadius(10)).shadow(radius: 2)
    }
}
