 MathQuest 🧮

**MathQuest** es una aplicación educativa inteligente diseñada para ayudar a los estudiantes a resolver y comprender problemas matemáticos paso a paso, potenciada por inteligencia artificial.

 Descripción
MathQuest transforma la forma en que los usuarios interactúan con las matemáticas. Mediante una interfaz intuitiva construida con SwiftUI y la potencia de la IA generativa a través de la API de Groq, la aplicación desglosa problemas complejos, ofrece soluciones detalladas y facilita el aprendizaje autónomo.

 Características Principales
*   **Resolución con IA:** Integración directa con modelos avanzados para obtener soluciones precisas y explicaciones pedagógicas.
*   **Interfaz Moderna:** Desarrollada con SwiftUI, ofreciendo una experiencia fluida y nativa en iOS.
*   **Backend Escalable:** Gestión de usuarios y persistencia de datos mediante Firebase.
*   **Seguridad:** Implementación de mejores prácticas para el manejo de llaves API y autenticación.
*   **Experiencia Educativa:** Diseño enfocado en la claridad para mejorar la retención del conocimiento.

 Tech Stack
| Capa | Tecnología |
| :--- | :--- |
| **Frontend** | Swift, SwiftUI |
| **Backend** | Firebase (Auth, Firestore) |
| IA/LLM | Groq API |
| Arquitectura| MVVM (Model-View-ViewModel) |

Arquitectura
La aplicación sigue una arquitectura clara para garantizar la estabilidad y escalabilidad:

1.  App (SwiftUI):** Interfaz de usuario donde el estudiante ingresa su consulta.
2.  Service Layer:** Gestor de peticiones que se comunica con **Groq API** para procesar el problema matemático.
3.  Firebase:** Gestiona la autenticación de usuarios y guarda el historial de problemas resueltos.

```mermaid
graph LR
    A[App SwiftUI] -->|Consulta| B(Groq API)
    B -->|Respuesta| A
    A -->|Auth/Data| C[Firebase]
