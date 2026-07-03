import Foundation

struct Pregunta: Codable, Identifiable, Hashable {
    let id: Int
    let textoPregunta: String
    let opciones: [String]
    let respuestaCorrecta: String
    let dificultad: Int
    let categoria: String

    var enunciado: String {
        textoPregunta
    }

    var esValida: Bool {
        !textoPregunta.isEmpty &&
        !opciones.isEmpty &&
        opciones.contains(respuestaCorrecta) &&
        (1...3).contains(dificultad)
    }

    static let placeholder = Pregunta(
        id: -1,
        textoPregunta: "Cargando pregunta...",
        opciones: ["1", "2", "3", "4"],
        respuestaCorrecta: "1",
        dificultad: 1,
        categoria: "6-8"
    )
}

struct BancoPreguntasResponse: Codable {
    let version: Int
    let descripcion: String
    let preguntas: [Pregunta]
}

enum PreguntasLocalDataSource {
    static let fileName = "preguntas"

    static func cargarDesdeBundle() throws -> [Pregunta] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw PreguntasDataError.archivoNoEncontrado
        }

        let data = try Data(contentsOf: url)
        return try decodificar(data)
    }

    static func cargarDesdeStringLocal() throws -> [Pregunta] {
        guard let data = samplePreguntasJSON.data(using: .utf8) else {
            throw PreguntasDataError.datosInvalidos
        }

        return try decodificar(data)
    }

    static func decodificar(_ data: Data) throws -> [Pregunta] {
        let decoder = JSONDecoder()
        let response = try decoder.decode(BancoPreguntasResponse.self, from: data)
        let preguntasValidas = response.preguntas.filter(\.esValida)

        guard !preguntasValidas.isEmpty else {
            throw PreguntasDataError.sinPreguntasValidas
        }

        return preguntasValidas
    }
}

enum PreguntasDataError: LocalizedError {
    case archivoNoEncontrado
    case datosInvalidos
    case sinPreguntasValidas

    var errorDescription: String? {
        switch self {
        case .archivoNoEncontrado:
            return "No se encontró el archivo local de preguntas."
        case .datosInvalidos:
            return "El contenido JSON de preguntas no es válido."
        case .sinPreguntasValidas:
            return "No hay preguntas válidas disponibles en el banco local."
        }
    }
}

let samplePreguntasJSON = """
{
  "version": 1,
  "descripcion": "Banco local inicial de preguntas de MathQuest",
  "preguntas": [
    {
      "id": 1,
      "textoPregunta": "¿Cuánto es 5 + 3?",
      "opciones": ["7", "8", "9", "10"],
      "respuestaCorrecta": "8",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 2,
      "textoPregunta": "¿Cuánto es 10 - 4?",
      "opciones": ["5", "6", "7", "8"],
      "respuestaCorrecta": "6",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 3,
      "textoPregunta": "Si tengo 3 manzanas y me dan 2, ¿cuántas tengo?",
      "opciones": ["4", "5", "6", "3"],
      "respuestaCorrecta": "5",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 4,
      "textoPregunta": "¿Qué número sigue al 19?",
      "opciones": ["18", "20", "21", "22"],
      "respuestaCorrecta": "20",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 5,
      "textoPregunta": "¿Cuánto es 2 + 2 + 2?",
      "opciones": ["4", "6", "8", "5"],
      "respuestaCorrecta": "6",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 6,
      "textoPregunta": "¿Cuánto es 7 + 6?",
      "opciones": ["12", "13", "14", "15"],
      "respuestaCorrecta": "13",
      "dificultad": 1,
      "categoria": "6-8"
    },
    {
      "id": 7,
      "textoPregunta": "¿Cuánto es 12 x 4?",
      "opciones": ["44", "46", "48", "50"],
      "respuestaCorrecta": "48",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 8,
      "textoPregunta": "¿Cuánto es 100 ÷ 5?",
      "opciones": ["20", "25", "15", "10"],
      "respuestaCorrecta": "20",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 9,
      "textoPregunta": "¿Cuál es el área de un cuadrado de lado 5?",
      "opciones": ["10", "20", "25", "30"],
      "respuestaCorrecta": "25",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 10,
      "textoPregunta": "¿Cuánto es 15 + 25?",
      "opciones": ["35", "40", "45", "50"],
      "respuestaCorrecta": "40",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 11,
      "textoPregunta": "¿Qué número es mayor?",
      "opciones": ["0.5", "0.25", "0.75", "0.1"],
      "respuestaCorrecta": "0.75",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 12,
      "textoPregunta": "Si compras 3 lápices de 4 monedas cada uno, ¿cuánto pagas?",
      "opciones": ["7", "10", "12", "14"],
      "respuestaCorrecta": "12",
      "dificultad": 2,
      "categoria": "9-12"
    },
    {
      "id": 13,
      "textoPregunta": "Resolver: 2x = 10. ¿Cuánto vale x?",
      "opciones": ["2", "5", "8", "10"],
      "respuestaCorrecta": "5",
      "dificultad": 3,
      "categoria": "13+"
    },
    {
      "id": 14,
      "textoPregunta": "¿Cuál es la raíz cuadrada de 81?",
      "opciones": ["7", "8", "9", "10"],
      "respuestaCorrecta": "9",
      "dificultad": 3,
      "categoria": "13+"
    },
    {
      "id": 15,
      "textoPregunta": "¿Cuánto es 3 al cubo (3³)?",
      "opciones": ["9", "18", "27", "30"],
      "respuestaCorrecta": "27",
      "dificultad": 3,
      "categoria": "13+"
    },
    {
      "id": 16,
      "textoPregunta": "Si x + 5 = 12, ¿cuánto es x?",
      "opciones": ["5", "6", "7", "8"],
      "respuestaCorrecta": "7",
      "dificultad": 3,
      "categoria": "13+"
    },
    {
      "id": 17,
      "textoPregunta": "¿Cuál es el 10% de 200?",
      "opciones": ["10", "20", "30", "40"],
      "respuestaCorrecta": "20",
      "dificultad": 3,
      "categoria": "13+"
    },
    {
      "id": 18,
      "textoPregunta": "Si 3x + 2 = 14, ¿cuánto vale x?",
      "opciones": ["2", "3", "4", "5"],
      "respuestaCorrecta": "4",
      "dificultad": 3,
      "categoria": "13+"
    }
  ]
}
"""
