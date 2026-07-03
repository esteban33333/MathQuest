import SwiftUI

struct RegistroView: View {
    @Environment(\.dismiss) var dismiss // Permite volver atrás al Login
    @EnvironmentObject var authViewModel: AuthViewModel

    // Campos del formulario ordenado alineados con tu AuthViewModel
    @State private var nombre = ""
    @State private var email = ""
    @State private var password = ""
    @State private var edad = 8

    var body: some View {
        ZStack {
            // Mismo estilo visual que tu Login
            LinearGradient(
                colors: [Color(red: 0.35, green: 0.80, blue: 1.0), Color(red: 0.35, green: 0.90, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 240, height: 240)
                .offset(x: -140, y: -260)

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 320, height: 320)
                .offset(x: 160, y: 260)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 10)

                    VStack(spacing: 8) {
                        Text("¡Únete a la Aventura!")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 10)

                        Text("Completa tus datos para guardar tus niveles")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        // 1. Nombre
                        campo(
                            titulo: "Nombre Completo",
                            systemImage: "person.fill",
                            text: $nombre,
                            keyboardType: .default,
                            capitalizacion: .words
                        )
                        
                        // 2. Edad con el diseño de tu selector original (Validado de 6 a 16 años)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("¿Cuántos años tienes?", systemImage: "birthday.cake.fill")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.black.opacity(0.7))

                            HStack {
                                Text("\(edad) años")
                                    .font(.headline.weight(.semibold))
                                Spacer()

                                Picker("Edad", selection: $edad) {
                                    ForEach(6...16, id: \.self) { age in
                                        Text("\(age) años").tag(age)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        // 3. Correo
                        campo(
                            titulo: "Correo electrónico",
                            systemImage: "envelope.fill",
                            text: $email,
                            keyboardType: .emailAddress,
                            capitalizacion: .never
                        )

                        // 4. Contraseña
                        campoSeguro(
                            titulo: "Crea una Contraseña",
                            systemImage: "lock.fill",
                            text: $password
                        )

                        // Botón: Finalizar Registro
                        Button(action: registrarse) {
                            Text("¡Comenzar!")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.25, green: 0.58, blue: 0.95))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 10)
                        }
                        .padding(.top, 6)

                        // Botón para volver al login de forma manual
                        Button("Volver al Inicio de Sesión") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)

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

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Quitamos la barra fea por defecto para usar tu diseño limpio
        .preferredColorScheme(.light)
    }

    // Reutilizamos tus mismos estilos
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

    private func registrarse() {
        // Pasamos únicamente los 4 parámetros que tu AuthViewModel maneja de forma nativa
        authViewModel.register(
            email: email,
            password: password,
            nombre: nombre,
            edad: edad
        )
    }
}
