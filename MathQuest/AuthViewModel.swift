import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

final class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var errorMessage: String?
    @Published var nombre: String = ""
    @Published var edad: Int = 8
    
    // Variables de progreso únicas del usuario
    @Published var estrellas: Int = 0
    @Published var nivelActual: Int = 1

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    private enum StorageKeys {
        static let nombreUsuario = "nombreUsuario"
        static let edadUsuario = "edadUsuario"
        static let esInvitado = "esInvitado"
    }

    init() {
        userSession = Auth.auth().currentUser
        cargarPerfilLocal()
        monitorearSesion()
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    // MARK: - Inicio de Sesión Tradicional
    func login(email: String, password: String) {
        let emailLimpio = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordLimpio = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !emailLimpio.isEmpty, !passwordLimpio.isEmpty else {
            errorMessage = "Completa tu correo y contraseña."
            return
        }

        errorMessage = nil

        Auth.auth().signIn(withEmail: emailLimpio, password: passwordLimpio) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.userSession = result?.user
                self?.errorMessage = nil
            }
        }
    }

    // MARK: - Registro Tradicional
    func register(email: String, password: String, nombre: String, edad: Int) {
        let emailLimpio = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordLimpio = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nombreLimpio.isEmpty else {
            errorMessage = "Ingresa un nombre válido."
            return
        }
        guard !emailLimpio.isEmpty, !passwordLimpio.isEmpty else {
            errorMessage = "Completa tu correo y contraseña."
            return
        }
        guard (6...16).contains(edad) else {
            errorMessage = "La edad debe estar entre 6 y 16 años."
            return
        }

        errorMessage = nil

        Auth.auth().createUser(withEmail: emailLimpio, password: passwordLimpio) { [weak self] result, error in
            guard let self = self else { return }
            if let error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }

            guard let uid = result?.user.uid else { return }
            
            // Guardar datos en Firestore vinculados al UID único
            let datos: [String: Any] = [
                "id": uid,
                "nombre": nombreLimpio,
                "email": emailLimpio,
                "edad": edad,
                "estrellas": 0,
                "nivelActual": 1
            ]

            self.db.collection("usuarios").document(uid).setData(datos) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.guardarPerfilLocal(nombre: nombreLimpio, edad: edad, esInvitado: false)
                    self.userSession = result?.user
                    self.nombre = nombreLimpio
                    self.edad = edad
                    self.estrellas = 0
                    self.nivelActual = 1
                    self.errorMessage = nil
                }
            }
        }
    }

    // MARK: - Autenticación con Google
    func loginConGoogle() {
        errorMessage = nil
        
        // 1. Obtener la escena de la interfaz de iOS
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
            self.errorMessage = "Error interno de la interfaz."
            return
        }
        
        // 2. Lanzar la ventana de Google
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            
            guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async { self.errorMessage = "Error al recuperar el token de Google." }
                return
            }
            
            // 3. Crear credenciales para Firebase Auth
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, firebaseError in
                if let firebaseError {
                    DispatchQueue.main.async { self.errorMessage = firebaseError.localizedDescription }
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                let nombreGoogle = result?.user.displayName ?? "Estudiante"
                let emailGoogle = result?.user.email ?? ""
                
                // 4. Verificar progreso independiente en Firestore
                self.db.collection("usuarios").document(uid).getDocument { document, _ in
                    DispatchQueue.main.async {
                        if let document = document, document.exists, let datos = document.data() {
                            // Usuario existente: cargar sus datos reales
                            self.nombre = datos["nombre"] as? String ?? nombreGoogle
                            self.edad = datos["edad"] as? Int ?? 8
                            self.estrellas = datos["estrellas"] as? Int ?? 0
                            self.nivelActual = datos["nivelActual"] as? Int ?? 1
                        } else {
                            // Usuario nuevo con Google: crear registro inicial
                            let nuevosDatos: [String: Any] = [
                                "id": uid,
                                "nombre": nombreGoogle,
                                "email": emailGoogle,
                                "edad": 8,
                                "estrellas": 0,
                                "nivelActual": 1
                            ]
                            self.db.collection("usuarios").document(uid).setData(nuevosDatos)
                            self.nombre = nombreGoogle
                            self.edad = 8
                            self.estrellas = 0
                            self.nivelActual = 1
                        }
                        
                        self.guardarPerfilLocal(nombre: self.nombre, edad: self.edad, esInvitado: false)
                        self.userSession = result?.user
                        self.errorMessage = nil
                    }
                }
            }
        }
    }

    // MARK: - Entrar Como Invitado
    func loginAsGuest() {
        errorMessage = nil
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                if let error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.guardarPerfilLocal(nombre: "Invitado", edad: 8, esInvitado: true)
                self?.userSession = result?.user
                self?.nombre = "Invitado"
                self?.edad = 8
                self?.estrellas = 0
                self?.nivelActual = 1
                self?.errorMessage = nil
            }
        }
    }

    // MARK: - Cerrar Sesión Súper Limpio (Evita mezclar datos)
    func logout() {
        DispatchQueue.main.async {
            try? Auth.auth().signOut()
            self.userSession = nil
            self.errorMessage = nil
            self.nombre = ""
            self.edad = 8
            self.estrellas = 0
            self.nivelActual = 1
            
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: StorageKeys.nombreUsuario)
            defaults.removeObject(forKey: StorageKeys.edadUsuario)
            defaults.removeObject(forKey: StorageKeys.esInvitado)
        }
    }

    // MARK: - Monitoreo de Sesión
    private func monitorearSesion() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userSession = user
                guard let self = self else { return }

                if let user {
                    if user.isAnonymous {
                        self.nombre = "Invitado"
                        self.edad = UserDefaults.standard.integer(forKey: StorageKeys.edadUsuario)
                        if self.edad == 0 { self.edad = 8 }
                    } else {
                        // Sincronizar datos desde Firestore si ya está logueado
                        self.db.collection("usuarios").document(user.uid).getDocument { doc, _ in
                            if let doc = doc, doc.exists, let datos = doc.data() {
                                DispatchQueue.main.async {
                                    self.nombre = datos["nombre"] as? String ?? "Estudiante"
                                    self.edad = datos["edad"] as? Int ?? 8
                                    self.estrellas = datos["estrellas"] as? Int ?? 0
                                    self.nivelActual = datos["nivelActual"] as? Int ?? 1
                                }
                            }
                        }
                    }
                } else {
                    self.nombre = ""
                    self.edad = 8
                }
            }
        }
    }

    private func cargarPerfilLocal() {
        let defaults = UserDefaults.standard
        nombre = defaults.string(forKey: StorageKeys.nombreUsuario) ?? ""
        let edadGuardada = defaults.integer(forKey: StorageKeys.edadUsuario)
        edad = edadGuardada == 0 ? 8 : edadGuardada
    }

    private func guardarPerfilLocal(nombre: String, edad: Int, esInvitado: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(nombre, forKey: StorageKeys.nombreUsuario)
        defaults.set(edad, forKey: StorageKeys.edadUsuario)
        defaults.set(esInvitado, forKey: StorageKeys.esInvitado)
    }
}
