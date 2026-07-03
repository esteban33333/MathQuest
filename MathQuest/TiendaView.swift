import SwiftUI

struct TiendaView: View {
    @EnvironmentObject private var cosmetics: CosmeticsStore
    @State private var mostrarErrorMonedas = false

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Monedas")
                        .font(.headline.weight(.black))
                    Spacer()
                    Text("\(cosmetics.coins)")
                        .font(.headline.weight(.black))
                }
            }

            Section {
                ForEach(cosmetics.sombreros) { item in
                    HStack(spacing: 12) {
                        MonstruoPreviewSombrero(hatId: item.id)
                            .frame(width: 52, height: 52)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.nombre)
                                .font(.headline.weight(.black))
                            Text(item.descripcion)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()

                        if cosmetics.estaComprado(item.id) {
                            if cosmetics.equippedHatId == item.id {
                                Button("Quitar") {
                                    cosmetics.equiparSombrero(nil)
                                }
                                .buttonStyle(.bordered)
                            } else {
                                Button("Usar") {
                                    cosmetics.equiparSombrero(item.id)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            Button("\(item.precio)") {
                                if !cosmetics.comprar(item) {
                                    mostrarErrorMonedas = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .overlay(alignment: .leading) {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.leading, 10)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            } header: {
                Text("Sombreros")
            } footer: {
                Text("Compra un sombrero y luego podrás activarlo o desactivarlo cuando quieras.")
            }
        }
        .navigationTitle("Tienda")
        .alert("No tienes suficientes monedas", isPresented: $mostrarErrorMonedas) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Gana monedas respondiendo preguntas correctamente.")
        }
    }
}

private struct MonstruoPreviewSombrero: View {
    @EnvironmentObject private var cosmetics: CosmeticsStore
    let hatId: String

    var body: some View {
        MonstruoView(estaComiendo: false, sombreroId: hatId)
            .scaleEffect(0.45)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
