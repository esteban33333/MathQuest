import Foundation
import Combine

struct Cosmetico: Identifiable, Hashable {
    let id: String
    let nombre: String
    let precio: Int
    let tipo: String // por ahora: "sombrero"
    let descripcion: String
}

final class CosmeticsStore: ObservableObject {
    private enum Keys {
        static let coins = "coins"
        static let purchasedCosmetics = "purchasedCosmetics" // ids separados por coma
        static let equippedHatId = "equippedHatId" // "" = nada
    }

    private let defaults = UserDefaults.standard

    @Published private(set) var coins: Int = 0
    @Published private(set) var purchased: Set<String> = []
    @Published var equippedHatId: String? = nil

    let sombreros: [Cosmetico] = [
        Cosmetico(id: "hat_cap", nombre: "Gorra", precio: 60, tipo: "sombrero", descripcion: "Un look deportivo."),
        Cosmetico(id: "hat_top", nombre: "Sombrero elegante", precio: 120, tipo: "sombrero", descripcion: "Estilo de jefe final."),
        Cosmetico(id: "hat_wizard", nombre: "Sombrero de mago", precio: 180, tipo: "sombrero", descripcion: "Poder matemágico.")
    ]

    init() {
        cargarDesdeStorage()
    }

    func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        defaults.set(coins, forKey: Keys.coins)
    }

    func comprar(_ item: Cosmetico) -> Bool {
        if purchased.contains(item.id) { return true }
        guard coins >= item.precio else { return false }
        coins -= item.precio
        defaults.set(coins, forKey: Keys.coins)

        purchased.insert(item.id)
        defaults.set(purchased.sorted().joined(separator: ","), forKey: Keys.purchasedCosmetics)
        return true
    }

    func estaComprado(_ id: String) -> Bool {
        purchased.contains(id)
    }

    func equiparSombrero(_ id: String?) {
        if let id {
            guard purchased.contains(id) else { return }
            equippedHatId = id
            defaults.set(id, forKey: Keys.equippedHatId)
        } else {
            equippedHatId = nil
            defaults.set("", forKey: Keys.equippedHatId)
        }
    }

    private func cargarDesdeStorage() {
        coins = defaults.integer(forKey: Keys.coins)

        let purchasedString = defaults.string(forKey: Keys.purchasedCosmetics) ?? ""
        purchased = Set(purchasedString.split(separator: ",").map(String.init))

        let equippedString = defaults.string(forKey: Keys.equippedHatId) ?? ""
        equippedHatId = equippedString.isEmpty ? nil : equippedString
    }
}
