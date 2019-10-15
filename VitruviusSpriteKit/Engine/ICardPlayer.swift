//
//  ICardPlayer.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol ICardPlayer {
    var cardZones: CardZones { get set }
}

class CardZones: Codable {
    
    let hand: Hand
    let drawPile: DrawPile
    let discard: DiscardPile
    
    init(hand: Hand, drawPile: DrawPile, discard: DiscardPile) {
        self.hand = hand
        self.drawPile = drawPile
        self.discard = discard
    }
    
    func discard(cardUuid: UUID) -> Void {
        
        guard let card = hand.cards.first(where: { (card) -> Bool in
            card.uuid == cardUuid
        }) else {
            return
        }
        
        hand.cards.removeAll { (card) -> Bool in
            card.uuid == cardUuid
        }
        
        discard.push(elt: card)
    }
    
    func remove(cardUuid: UUID) -> Void {
        hand.cards.removeAll { (card) -> Bool in
            card.uuid == cardUuid
        }
    }
    
    static func newEmpty() -> CardZones {
        return CardZones(
            hand: Hand.newEmpty(),
            drawPile: DrawPile.newEmpty(),
            discard: DiscardPile.init()
        )
    }
}

class Hand: Codable {
    
    var cards: [Card]
    
    init(cards: [Card] = []) {
        self.cards = cards
    }
    
    func cardWith(uuid: UUID) -> Card? {
        return cards.first { (c) -> Bool in
            c.uuid == uuid
        }
    }
    
    static func newEmpty() -> Hand {
        return Hand()
    }
}

enum CardDraw: Codable {
    
    case specific(Card)
    case random
    
    private enum CodingKeys: String, CodingKey {
        case type
        case card
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        
        switch type {
        case "specific":
            let card = try values.decode(Card.self, forKey: .card)
            self = .specific(card)
        default:
            self = .random
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .random:
            try container.encode("random", forKey: .type)
        case .specific(let c):
            try container.encode("specific", forKey: .type)
            try container.encode(c, forKey: .card)
        }
    }
    
}


class DrawPile: Codable {
    
    var randomPool: [Card]
    var draws: [CardDraw]
    
    var count: Int {
        get { return draws.count }
    }
    
    init(cards: [Card]) {
        self.randomPool = cards
        self.draws = self.randomPool.map({ _ in return .random })
    }
    
    func hasDraw() -> Bool {
        return draws.count > 0
    }
    
    func shuffleIn(cards: [Card]) {
        self.randomPool += cards
        self.draws = self.randomPool.map({ _ in return .random })
    }
    
    func drawRandom() -> Card? {
        
        let draw = self.draws.remove(at: 0)
        
        switch draw {
        
        case .specific(let card):
            return card
            
        case .random:
            let i = (0...self.randomPool.count-1).randomElement()!
            return self.randomPool.remove(at: i)
        }
    }

    static func newEmpty() -> DrawPile {
        return DrawPile(cards: [])
    }

}

class DiscardPile : StackQueue<Card> {
    
    
}
