import SwiftUI

struct NivelesView: View {
    @AppStorage("edadUsuario") private var edadUsuario = 9
    @State private var modoSeleccionado: GameMode = .clasico

    var body: some View {
        List {
            Section {
                Picker("Modo", selection: $modoSeleccionado) {
                    Text("Clásico").tag(GameMode.clasico)
                    Text("Vs IA").tag(GameMode.vsIA)
                }
                .pickerStyle(.segmented)
            }

            ForEach(Dificultad.allCases) { dif in
                Section {
                    ForEach(niveles.filter { $0.dificultad == dif }) { nivel in
                        NavigationLink {
                            LevelLaunchView(modo: modoSeleccionado, edad: edadUsuario, dificultad: dif)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack(spacing: 12) {
                                // Aquí llamamos a tu vista de monstruo
                                ZStack {
                                    Circle().fill(color(for: dif).opacity(0.2)).frame(width: 40, height: 40)
                                    Text("\(nivel.numero)")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundColor(color(for: dif))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Nivel \(nivel.numero): \(nivel.nombre)")
                                        .font(.headline.weight(.black))
                                    Text(dif.descripcion)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                } header: {
                    Text(dif.titulo.uppercased())
                }
            }
        }
        .navigationTitle("Niveles")
    }

    private func color(for dificultad: Dificultad) -> Color {
        switch dificultad {
        case .facil: return .green
        case .media: return .blue
        case .dificil: return .purple
        }
    }
}

/// Pantalla puente que conecta la selección con el juego
private struct LevelLaunchView: View {
    let modo: GameMode
    let edad: Int
    let dificultad: Dificultad

    var body: some View {
        Group {
            switch modo {
            case .clasico:
                JuegoView(edad: edad, dificultadInicial: dificultad.rawValue, dificultadFija: true)
            case .vsIA:
                // ESTA LÍNEA DEBE COINCIDIR EXACTAMENTE CON EL INIT DE BATALLAIAVIEW
                BatallaIAView(edad: edad, dificultad: dificultad.rawValue)
            }
        }
    }
}
