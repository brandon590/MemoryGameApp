//
//  CardGameViewModel.swift
//  Assignment_3_Memory_Game_App
//
//  Created by Brandon Baker on 2/25/26.
//

import Foundation
import SwiftUI
import Combine

// This is the ViewModel for the memory game.
// It handles all the game logic and updates the UI when things change.
final class CardGameViewModel: ObservableObject {

    @Published var cards: [Card] = []   // Array of all cards in the game
    @Published var score: Int = 0       // Player's score
    @Published var moves: Int = 0       // Number of moves made
    @Published var gameOver: Bool = false       // Becomes true when all cards are matched

    // Stores the ID of the first selected card (if there is one)
    private var firstSelectedCardID: UUID? = nil

    // Fixed set of emojis used for the game
    private let emojis: [String] = ["😀","🎮","🍕","🚗","🐶","🌟","⚽️","🎵"]

    init() {
        startNewGame()
    }

    // Starts or resets the game
    func startNewGame() {
        // Create pairs of emojis
        var paired: [String] = []
        for e in emojis {
            paired.append(e)
            paired.append(e)
        }

        // Convert each emoji into a Card object
        cards = paired.map { Card(content: $0) }

        // Reset game stats
        score = 0
        moves = 0
        gameOver = false
        firstSelectedCardID = nil

        shuffleCards()  // Shuffle the cards so they aren't in order
    }

    // Randomizes the order of the cards
    func shuffleCards() {
        cards.shuffle()
    }

    // Handles what happens when a card is tapped
    func selectCard(_ selected: Card) {
        // Find the index of the tapped card
        guard let selectedIndex = cards.firstIndex(where: { $0.id == selected.id }) else { return }

        // If the card is already matched or face up, ignore the tap
        if cards[selectedIndex].isMatched || cards[selectedIndex].isFaceUp {
            return
        }

        // If a first card was already selected
        if let firstID = firstSelectedCardID,
           let firstIndex = cards.firstIndex(where: { $0.id == firstID }) {

            // This is the second card selected
            moves += 1
            cards[selectedIndex].isFaceUp = true

            // Check if the two cards match
            if cards[selectedIndex].content == cards[firstIndex].content {
                
                // If they match, mark both as matched
                cards[selectedIndex].isMatched = true
                cards[firstIndex].isMatched = true
                score += 2

                // If all cards are matched, game is over
                if cards.allSatisfy({ $0.isMatched }) {
                    gameOver = true
                }
            } else {
                // If they don't match, subtract a point (but not below 0)
                if score > 0 { score -= 1 }
            }

            // Reset the first selected card
            firstSelectedCardID = nil

        } else {
            // First card selected:
            // Turn all unmatched cards face down
            for i in cards.indices {
                if !cards[i].isMatched {
                    cards[i].isFaceUp = false
                }
            }

            // Store the first selected card
            firstSelectedCardID = cards[selectedIndex].id
            cards[selectedIndex].isFaceUp = true
        }
    }
}
