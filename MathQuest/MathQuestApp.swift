import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MathQuestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Creamos los dos motores: la sesión y la tienda de cosméticos
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var cosmeticsStore = CosmeticsStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.userSession == nil {
                    LoginView()
                } else {
                    MainTabView()
                }
            }
            .preferredColorScheme(.light)
            // Aquí les heredamos ambos datos a todas las vistas de la app
            .environmentObject(authViewModel)
            .environmentObject(cosmeticsStore)
            .onAppear {
                // Arrancamos la música de fondo al iniciar la app
                SoundManager.shared.playBackgroundMusic(named: "adventure")
            }
        }
    }
}
