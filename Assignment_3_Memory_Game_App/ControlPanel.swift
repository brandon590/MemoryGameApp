//
//  ControlPanel.swift
//  Assignment_3_Memory_Game_App
//
//  Created by Brandon Baker on 2/25/26.
//

import SwiftUI

// This view displays the score, moves, and control buttons for the game
struct ControlPanel: View {
    
    // Observes the ViewModel so the UI updates when score, moves, or gameOver changes
    @ObservedObject var viewModel: CardGameViewModel

    // These closures are passed in from the parent view
    // They tell the app what to do when buttons are pressed
    let onNewGame: () -> Void
    let onShuffle: () -> Void

    // Used to animate the "You Win" message
    @State private var winPulse = false

    var body: some View {
        VStack(spacing: 10) {
            // Displays the current score and number of moves
            HStack {
                Text("Score: \(viewModel.score)")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text("Moves: \(viewModel.moves)")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            // Buttons for starting a new game and shuffling cards
            HStack(spacing: 10) {
                Button("New Game") {
                    // Adds a spring animation when starting a new game
                    withAnimation(.spring()) {
                        onNewGame()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Shuffle") {
                    // Adds animation when shuffling the cards
                    withAnimation(.spring()) {
                        onShuffle()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            // Shows this message only when the game is over
            if viewModel.gameOver {
                Text("🎉 You Win!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 18)
                    .background(
                        // Green rounded background behind the win text
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.green.opacity(0.95))
                            .shadow(color: .green.opacity(0.55), radius: 25, x: 0, y: 10)
                    )
                    // Slight pulsing animation to make it stand out
                    .scaleEffect(winPulse ? 1.08 : 0.95)
                    .opacity(winPulse ? 1 : 0.8)
                    .onAppear {
                        winPulse = false
                        // Repeating animation so the win message pulses
                        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                            winPulse = true
                        }
                    }
            }
        }
        .padding()
        // Glass-style background for the control panel
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)
        )
    }
}
