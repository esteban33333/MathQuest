import SwiftUI

struct MonstruoView: View {
    @EnvironmentObject private var cosmetics: CosmeticsStore
    var estaComiendo: Bool
    var sombreroId: String? = nil
    
    var body: some View {
        ZStack {
            // Cuerpo
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.purple)
                .frame(width: 120, height: 120)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.black.opacity(0.2), lineWidth: 5))
            
            VStack {
                // Ojos
                HStack(spacing: 20) {
                    Circle().fill(Color.white).frame(width: 30, height: 30)
                        .overlay(Circle().fill(Color.black).frame(width: 10, height: 10))
                    Circle().fill(Color.white).frame(width: 30, height: 30)
                        .overlay(Circle().fill(Color.black).frame(width: 10, height: 10))
                }
                
                // Boca
                if estaComiendo {
                    Capsule().fill(Color.black).frame(width: 60, height: 30) // Boca abierta
                } else {
                    Rectangle().fill(Color.black).frame(width: 40, height: 5).cornerRadius(2) // Boca normal
                }
            }
            
            // Cuernos
            HStack(spacing: 70) {
                Capsule().fill(Color.purple).frame(width: 20, height: 40).rotationEffect(.degrees(-30))
                Capsule().fill(Color.purple).frame(width: 20, height: 40).rotationEffect(.degrees(30))
            }
            .offset(y: -60)

            sombreroView
        }
        .shadow(radius: 10)
    }

    @ViewBuilder
    private var sombreroView: some View {
        let id = sombreroId ?? cosmetics.equippedHatId
        switch id {
        case "hat_cap":
            GorraView()
                .offset(y: -78)
        case "hat_top":
            SombreroEleganteView()
                .offset(y: -84)
        case "hat_wizard":
            SombreroMagoView()
                .offset(y: -92)
        default:
            EmptyView()
        }
    }
}

private struct GorraView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.15, green: 0.55, blue: 0.95))
                .frame(width: 92, height: 30)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.25), lineWidth: 2))

            Capsule()
                .fill(Color(red: 0.10, green: 0.45, blue: 0.85))
                .frame(width: 58, height: 22)
                .offset(y: -12)

            Capsule()
                .fill(Color(red: 0.10, green: 0.45, blue: 0.85))
                .frame(width: 46, height: 12)
                .offset(x: 30, y: 10)
        }
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 6)
    }
}

private struct SombreroEleganteView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 100, height: 16)
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black)
                .frame(width: 62, height: 44)
                .offset(y: -20)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(red: 0.80, green: 0.20, blue: 0.35))
                .frame(width: 60, height: 10)
                .offset(y: -10)
        }
        .shadow(color: .black.opacity(0.20), radius: 8, x: 0, y: 8)
    }
}

private struct SombreroMagoView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color(red: 0.15, green: 0.10, blue: 0.35))
                .frame(width: 110, height: 18)

            TriangleShape()
                .fill(Color(red: 0.35, green: 0.25, blue: 0.85))
                .frame(width: 74, height: 84)
                .offset(y: -34)
                .overlay(
                    TriangleShape()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )

            Circle()
                .fill(Color.yellow)
                .frame(width: 10, height: 10)
                .offset(x: 8, y: -62)
        }
        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 8)
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
