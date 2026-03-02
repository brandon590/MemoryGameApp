//
//  MainGameView.swift
//  Assignment_3_Memory_Game_App
//
//  Created by Brandon Baker on 2/25/26.
//

import SwiftUI
// This is the main view of the game.
// It controls the layout, background, grid of cards, and control panel.
struct MainGameView: View {

    // ViewModel that handles all the game logic
    @StateObject private var viewModel = CardGameViewModel()
    // Keeps track of which cards have been dealt (for animation)
    @State private var dealt: Set<UUID> = []

    var body: some View {
        // GeometryReader lets us detect screen size (used for landscape vs portrait)
        GeometryReader { geo in
            ZStack {
                
                // Custom background (glass style gradient + glow)
                GlassBackground()
                    .ignoresSafeArea()

                // Check if the device is in landscape
                let isLandscape = geo.size.width > geo.size.height

            
                Group {
                    if isLandscape {
                        
                        // LANDSCAPE layout:
                        // Cards on the left, control panel on the right
                        HStack(spacing: 12) {
                            cardGrid(screenSize: geo.size, isLandscape: true)

                            VStack {
                                Spacer()

                                ControlPanel(
                                    viewModel: viewModel,
                                    onNewGame: {
                                        viewModel.startNewGame()
                                        redealCards()
                                    },
                                    onShuffle: {
                                        viewModel.shuffleCards()
                                        redealCards()
                                    }
                                )
                                .frame(width: 280)          // fixed width panel
                                .padding(.trailing, 16)      // breathing room from right edge

                                Spacer()
                            }
                        }
                       

                    } else {
                        
                        // PORTRAIT layout:
                       // Cards on top, control panel below
                        VStack(spacing: 12) {
                            cardGrid(screenSize: geo.size, isLandscape: false)

                            ControlPanel(
                                viewModel: viewModel,
                                onNewGame: {
                                    viewModel.startNewGame()
                                    redealCards()
                                },
                                onShuffle: {
                                    viewModel.shuffleCards()
                                    redealCards()
                                }
                            )
                            // Keeps the control panel centered
                            .frame(width: min(geo.size.width * 0.95, 360))
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.vertical, 25)
                        .padding(.horizontal, 25)          
                    }
                }
                // Animate layout change when orientation changes
                .animation(.spring(), value: isLandscape)

                // Show confetti when the game is over
                if viewModel.gameOver {
                    ConfettiBurstView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            // When the view first appears, deal the cards
            .onAppear { redealCards() }
        }
    }
    // Creates the grid of cards
    private func cardGrid(screenSize: CGSize, isLandscape: Bool) -> some View {
        // Cards are slightly bigger in landscape
        let minWidth: CGFloat = isLandscape ? 100 : 80
        // Adaptive grid so it adjusts automatically
        let columns = [GridItem(.adaptive(minimum: minWidth), spacing: 8)]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.cards) { card in
                    CardView(
                        viewModel: viewModel,
                        card: card,
                        isDealt: dealt.contains(card.id)
                    )
                    .aspectRatio(2/3, contentMode: .fit)
                }
            }
            .padding(6)
        }
        .padding(.horizontal, 4)
    }

    // Deals cards with a small delay so they animate in one by one
    private func dealCards() {
        for (index, card) in viewModel.cards.enumerated() {
            let delay = Double(index) * 0.1
            withAnimation(.spring().delay(delay)) {
                dealt.insert(card.id)
            }
        }
    }

    // Clears and re-deals cards (used for new game and shuffle)
    private func redealCards() {
        dealt.removeAll()
        dealCards()
    }
}


private struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.55),
                    Color.red.opacity(0.65),
                    Color.black.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 420, height: 420)
                .blur(radius: 110)
                .offset(x: -160, y: -220)

            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 340, height: 340)
                .blur(radius: 110)
                .offset(x: 220, y: 320)
        }
    }
}

// Confetti burst (runs once when shown)
private struct ConfettiBurstView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let size: CGFloat
        let delay: Double
        let duration: Double
        let color: Color
        let spin: Double
    }

    @State private var animate = false
    @State private var pieces: [Piece] = []

    var body: some View {
        ZStack {
            ForEach(pieces) { p in
                RoundedRectangle(cornerRadius: 3)
                    .fill(p.color)
                    .frame(width: p.size * 0.6, height: p.size)
                    .rotationEffect(.degrees(animate ? p.spin : 0))
                    .offset(x: p.x, y: animate ? 900 : -120)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeOut(duration: p.duration).delay(p.delay), value: animate)
            }
        }
        .onAppear {
            if pieces.isEmpty {
                pieces = (0..<34).map { _ in
                    Piece(
                        x: CGFloat.random(in: -180...180),
                        size: CGFloat.random(in: 8...16),
                        delay: Double.random(in: 0...0.35),
                        duration: Double.random(in: 1.1...1.9),
                        color: [.pink, .yellow, .green, .cyan, .orange, .purple, .white].randomElement()!,
                        spin: Double.random(in: 180...720)
                    )
                }
            }
            animate = true
        }
    }
}
