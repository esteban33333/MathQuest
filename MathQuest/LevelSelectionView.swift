import SwiftUI

struct LevelSelectionView: View {
    let modo: GameMode
    let edad: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(modo == .clasico ? "Elige tu nivel" : "Elige nivel para pelear")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .padding(.top, 6)

                ForEach(Dificultad.allCases) { dif in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(dif.titulo)
                                .font(.title2.weight(.black))
                            Text("• \(dif.descripcion)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                            ForEach(niveles.filter { $0.dificultad == dif }) { nivel in
                                NavigationLink {
                                    switch modo {
                                    case .clasico:
                                        JuegoView(edad: edad, dificultadInicial: dif.rawValue, dificultadFija: true)
                                    case .vsIA:
                                        BatallaIAView(edad: edad, dificultad: dif.rawValue)
                                    }
                                } label: {
                                    NivelCardView(nivel: nivel, color: color(for: dif))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationTitle("Niveles")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func color(for dificultad: Dificultad) -> Color {
        switch dificultad {
        case .facil: return Color(red: 0.25, green: 0.75, blue: 0.40)
        case .media: return Color(red: 0.25, green: 0.55, blue: 0.95)
        case .dificil: return Color(red: 0.75, green: 0.30, blue: 0.95)
        }
    }
}

private struct NivelCardView: View {
    let nivel: Nivel
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MonstruoView(estaComiendo: false)
                    .scaleEffect(0.28)
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 2)

                ZStack {
                    Circle().fill(color.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Text("\(nivel.numero)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(color)
                }
                Spacer()
            }

            Text(nivel.nombre)
                .font(.headline.weight(.black))
                .foregroundColor(.black)

            Text("Nivel \(nivel.numero)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.20), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 8)
    }
}
