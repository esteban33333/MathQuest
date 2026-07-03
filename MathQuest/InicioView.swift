import SwiftUI

struct InicioView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("nombreUsuario") private var nombreUsuario = ""
    @AppStorage("edadUsuario") private var edadUsuario = 9

    @State private var animarFondo = false

    var body: some View {
        ZStack {
            fondo

            ScrollView {
                VStack(spacing: 16) {
                    header

                    VStack(spacing: 12) {
                        card {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tu edad")
                                        .font(.headline.weight(.black))
                                    Text("Esto ajusta el tipo de retos (puedes cambiarlo cuando quieras).")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }

                            Picker("Edad", selection: $edadUsuario) {
                                ForEach(6...16, id: \.self) { age in
                                    Text("\(age) años").tag(age)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 6)
                        }

                        NavigationLink {
                            LevelSelectionView(modo: .clasico, edad: edadUsuario)
                        } label: {
                            primaryButtonLabel(
                                titulo: "Empezar",
                                subtitulo: "Elige un nivel y gana estrellas",
                                systemImage: "play.fill",
                                color: Color(red: 0.35, green: 0.75, blue: 0.95)
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            LevelSelectionView(modo: .vsIA, edad: edadUsuario)
                        } label: {
                            primaryButtonLabel(
                                titulo: "Pelear con IA",
                                subtitulo: "Compite por el mejor puntaje",
                                systemImage: "brain.head.profile",
                                color: Color(red: 0.72, green: 0.35, blue: 0.95)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    card {
                        HStack(spacing: 12) {
                            MonstruoView(estaComiendo: false)
                                .scaleEffect(0.55)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tip del día")
                                    .font(.headline.weight(.black))
                                Text("Responde sin apurarte: primero piensa, luego elige.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Inicio")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Salir") {
                    authViewModel.logout()
                }
                    .font(.headline.weight(.bold))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                animarFondo = true
            }
        }
    }

    private var fondo: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(red: 0.7, green: 0.9, blue: 1.0)
                CloudShape()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 220, height: 110)
                    .offset(x: animarFondo ? 520 : -520, y: -70)
                CloudShape()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 160, height: 85)
                    .offset(x: animarFondo ? -520 : 520, y: -140)
            }
            ZStack(alignment: .top) {
                Color(red: 0.4, green: 0.85, blue: 0.45)
                Rectangle().fill(Color.black.opacity(0.06)).frame(height: 10)
            }
            .frame(height: 210)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hola, \(nombreUsuario.isEmpty ? "Jugador" : nombreUsuario)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                Text("Hoy toca subir de nivel.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.top, 6)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(16)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 10)
    }

    private func primaryButtonLabel(titulo: String, subtitulo: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.white.opacity(0.22))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitulo)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.95))
            }
            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline.weight(.black))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: color.opacity(0.35), radius: 18, x: 0, y: 12)
    }
}
