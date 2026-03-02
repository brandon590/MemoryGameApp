import Foundation
import SwiftUI

struct Card: Identifiable, Equatable {
    let id: UUID = UUID()
    let content: String            // emoji
    var isFaceUp: Bool = false
    var isMatched: Bool = false

    // Assignment says "position on screen as CGFloat and set to zero"
    var position: CGFloat = 0
}