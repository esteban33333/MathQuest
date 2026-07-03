import SwiftUI

// Forma reutilizable para las nubes del fondo
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: CGRect(x: rect.width * 0.2, y: 0, width: rect.width * 0.6, height: rect.height))
        path.addEllipse(in: CGRect(x: 0, y: rect.height * 0.2, width: rect.width * 0.5, height: rect.height * 0.8))
        path.addEllipse(in: CGRect(x: rect.width * 0.5, y: rect.height * 0.2, width: rect.width * 0.5, height: rect.height * 0.8))
        return path
    }
}

