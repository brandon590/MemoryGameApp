//
//  CardView.swift
//  Assignment_3_Memory_Game_App
//
//  Created by Brandon Baker on 2/25/26.
//

import SwiftUI

struct CardView: View {
    // We observe the ViewModel so the UI updates when game state changes
    @ObservedObject var viewModel: CardGameViewModel
    
    // The specific card this view is displaying
    let card: Card

    // Used to control the deal animation from the parent view
    let isDealt: Bool

    // Used to track how much the card is being dragged
    @State private var dragAmount: CGSize = .zero
    
    // Used to track how much the card is rotated
    @State private var rotation: Angle = .zero

    var body: some View {
        ZStack {
            // FRONT SIDE OF THE CARD
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 2)
                .overlay(
                    Text(card.content)
                        .font(.largeTitle)
                )
                .opacity(card.isFaceUp ? 1 : 0)

            // BACK SIDE OF THE CARD (image background)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.clear)
                .overlay(
                    Image("cardBack")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                .opacity(card.isFaceUp ? 0 : 1)
        }

        // If the card is matched, make it slightly transparent
        .opacity(card.isMatched ? 0.4 : 1.0)

        // 3D flip animation when the card turns over
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )

        // Allows the card to rotate with a rotation gesture
        .rotationEffect(rotation)

        // Allows the card to move while dragging
        .offset(dragAmount)

        // Controls the deal animation (cards fade and slide in)
        .opacity(isDealt ? 1 : 0)
        .offset(y: isDealt ? 0 : 30)

        // Animates flip changes smoothly
        .animation(.default, value: card.isFaceUp)

        // Drag gesture (card follows finger, then snaps back)
        .gesture(
            DragGesture()
                .onChanged { dragAmount = $0.translation }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        dragAmount = .zero
                    }
                }
        )

        // Rotation gesture (card rotates, then snaps back)
        .gesture(
            RotationGesture()
                .onChanged { rotation = $0 }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        rotation = .zero
                    }
                }
        )

        // Tap gesture flips/selects the card
        .onTapGesture {
            withAnimation(.spring()) {
                viewModel.selectCard(card)
            }
        }

        // Prevents tapping if the card hasn't been dealt yet
        // or if it has already been matched
        .allowsHitTesting(isDealt && !card.isMatched)
    }
}
