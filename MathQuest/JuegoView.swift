import SwiftUI

struct JuegoView: View {
    @EnvironmentObject private var cosmetics: CosmeticsStore
    let edad: Int
    var dificultadInicial: Int? = nil
    var dificultadFija: Bool = false
    @StateObject private var viewModel = JuegoViewModel()
    @State private var vidas = 3
    @State private var mostrarFeedback = false
    @State private var esCorrecto = false
    @State private var monstruoComiendo = false
    @State private var mostrarResultados = false
    @State private var animarFondo = false
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            ZStack {
                fondo
                
                if isLandscape {
                    layoutHorizontal
                } else {
                    layoutVertical
                }
                
                if mostrarFeedback {
                    VStack {
                        Spacer()
                        Text(esCorrecto ? "¡MUY BIEN! 🎉" : "¡EL MONSTRUO TE COMIÓ! 😋")
                            .font(.title2.bold()).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(28)
                            .background(esCorrecto ? Color.green : Color.red)
                    }
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            viewModel.configurarJuego(edad: edad, dificultadInicial: dificultadInicial, dificultadFija: dificultadFija)
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                animarFondo = true
            }
        }
        .sheet(isPresented: $mostrarResultados) {
            ResultadosView(
                puntos: viewModel.estrellas,
                rondasJugadas: viewModel.preguntasRespondidas,
                rondasTotales: viewModel.totalRondas
            )
        }
    }

    private var fondo: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(red: 0.7, green: 0.9, blue: 1.0)
                CloudShape()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 180, height: 90)
                    .offset(x: animarFondo ? 450 : -450, y: -50)
            }
            Color(red: 0.4, green: 0.8, blue: 0.4).frame(height: 200)
        }
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(viewModel.estrellas)").font(.title2.bold())
            }
            .padding(12).background(Color.white.opacity(0.9)).cornerRadius(20)
            
            Spacer()
            
            HStack {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < vidas ? "heart.fill" : "heart.slash")
                        .foregroundColor(.red).font(.title2)
                }
            }
        }
        .padding()
    }

    private var questionCard: some View {
        ScrollView {
            Text(viewModel.preguntaActual.textoPregunta)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: 140)
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(radius: 10)
        .padding(.horizontal)
    }

    private var optionsGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.preguntaActual.opciones, id: \.self) { opcion in
                    Button(action: { validar(opcion) }) {
                        Text(opcion)
                            .font(.title3.bold())
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.28)).offset(y: 3)
                                    RoundedRectangle(cornerRadius: 15).fill(Color.white)
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(mostrarFeedback)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .scrollIndicators(.hidden)
    }

    private var layoutVertical: some View {
        VStack {
            topBar
            Spacer(minLength: 0)
            
            VStack(spacing: 16) {
                MonstruoView(estaComiendo: monstruoComiendo)
                    .scaleEffect(monstruoComiendo ? 1.15 : 1.0)
                
                questionCard
            }
            
            Spacer(minLength: 0)
            optionsGrid
        }
    }

    private var layoutHorizontal: some View {
        VStack(spacing: 0) {
            topBar
            
            HStack(spacing: 12) {
                VStack(spacing: 12) {
                    MonstruoView(estaComiendo: monstruoComiendo)
                        .scaleEffect(monstruoComiendo ? 1.10 : 0.95)
                    Text("Elige la respuesta")
                        .font(.headline.weight(.black))
                        .foregroundColor(.secondary)
                }
                .frame(width: 220)
                .padding(.leading, 10)
                
                VStack(spacing: 10) {
                    questionCard
                    optionsGrid
                }
            }
        }
    }
    
    func validar(_ seleccion: String) {
        esCorrecto = (seleccion == viewModel.preguntaActual.respuestaCorrecta)
        withAnimation {
            mostrarFeedback = true
            if !esCorrecto {
                vidas -= 1
                monstruoComiendo = true
            } else {
                // Monedas por acertar
                cosmetics.addCoins(10)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                monstruoComiendo = false
                mostrarFeedback = false
                viewModel.procesarRespuesta(fueCorrecta: esCorrecto)
                if vidas <= 0 || viewModel.preguntasRespondidas >= 5 {
                    mostrarResultados = true
                }
            }
        }
    }
}
