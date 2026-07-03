import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // El Login solo necesita Correo y Contraseña
    @State private var email = ""
    @State private var password = ""
    
    // Controla si se abre la pantalla de registro
    @State private var mostrarRegistro = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Tu Gradiente original
                LinearGradient(
                    colors: [Color(red: 0.35, green: 0.80, blue: 1.0), Color(red: 0.35, green: 0.90, blue: 0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 240, height: 240)
                    .offset(x: 140, y: -260)

                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 320, height: 320)
                    .offset(x: -160, y: 260)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        Spacer(minLength: 24)

                        VStack(spacing: 8) {
                            Text("MathQuest")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 10)

                            Text("Aprende jugando, sube de nivel y reta a la IA")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        MonstruoView(estaComiendo: false)
                            .scaleEffect(0.9)
                            .padding(.top, 6)

                        // Caja con los controles de Login
                        VStack(spacing: 14) {
                            campo(
                                titulo: "Correo electrónico",
                                systemImage: "envelope.fill",
                                text: $email,
                                keyboardType: .emailAddress,
                                capitalizacion: .never
                            )

                            campoSeguro(
                                titulo: "Contraseña",
                                systemImage: "lock.fill",
                                text: $password
                            )

                            // Botón: Iniciar Sesión
                            Button(action: iniciarSesion) {
                                Text("Iniciar Sesión")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(red: 0.20, green: 0.75, blue: 0.35))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 10)
                            }
                            .padding(.top, 6)

                            // Botón de Google elegante personalizado con SwiftUI
                            Button(action: entrarConGoogle) {
                                HStack(spacing: 12) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.title3)
                                    Text("Continuar con Google")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 4)
                            }

                            // Entrar como Invitado
                            Button(action: entrarComoInvitado) {
                                Text("Entrar como invitado")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                            }

                            // Enlace directo a la vista ordenada de Registro
                            Button(action: { mostrarRegistro = true }) {
                                Text("¿No tienes cuenta? **Regístrate aquí**")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 4)

                            Text("Tus datos se guardan de forma segura para sincronizar tu progreso.")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(.white.opacity(0.92))
                                .multilineTextAlignment(.center)

                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.footnote.weight(.bold))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .opacity(0.95)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                        Spacer(minLength: 16)
                    }
                    .padding(.vertical, 12)
                }
            }
            // Esto abre la nueva pantalla de registro de forma fluida
            .navigationDestination(isPresented: $mostrarRegistro) {
                RegistroView()
            }
        }
        .preferredColorScheme(.light)
    }

    // Tus funciones auxiliares de diseño de campos se quedan igual
    private func campo(titulo: String, systemImage: String, text: Binding<String>, keyboardType: UIKeyboardType, capitalizacion: TextInputAutocapitalization) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.black.opacity(0.6))
                .frame(width: 22)
            TextField(titulo, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(capitalizacion)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func campoSeguro(titulo: String, systemImage: String, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.black.opacity(0.6))
                .frame(width: 22)
            SecureField(titulo, text: text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func iniciarSesion() {
        authViewModel.login(email: email, password: password)
    }

    private func entrarConGoogle() {
        authViewModel.loginConGoogle()
    }

    private func entrarComoInvitado() {
        authViewModel.loginAsGuest()
    }
}
