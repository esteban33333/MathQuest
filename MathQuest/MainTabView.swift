import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                InicioView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }

            NavigationStack {
                NivelesView()
            }
            .tabItem {
                Label("Niveles", systemImage: "flag.checkered")
            }

            NavigationStack {
                TiendaView()
            }
            .tabItem {
                Label("Tienda", systemImage: "bag.fill")
            }
        }
        .preferredColorScheme(.light)
    }
}
