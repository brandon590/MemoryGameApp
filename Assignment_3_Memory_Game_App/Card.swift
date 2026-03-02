//
//  Card.swift
//  Assignment_3_Memory_Game_App
//
//  Created by Brandon Baker on 2/25/26.
//


import Foundation
import SwiftUI

// This struct represents a single card in the memory game
struct Card: Identifiable, Equatable {
    
    let id: UUID = UUID() // Each card gets a unique id so SwiftUI can track it in lists/grids
    let content: String    // The actual content of the card (in this case an emoji)
    var isFaceUp: Bool = false   // Tracks whether the card is currently flipped face up
    var isMatched: Bool = false // Tracks whether the card has already been matched

    var position: CGFloat = 0   // The assignment required a position value (default starts at 0)
}
