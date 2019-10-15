//
//  ICard.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


enum CardAttributes {
    case attack
    case spell
    case melee
    case ranged
    case buff
    case debuff
    case defence
    case heal
    case summons
}




protocol CardStrategy {
    
    var cardNumber: Int { get }
    var name: String { get }
    var requiresSingleTarget: Bool { get }
    var cost: Int { get set }
    var cardText: String { get }
    
    func resolve(cardUuid: UUID, source: Actor, battleState: BattleState, target: Actor?) -> Void
    func onDrawn(source: Actor, battleState: BattleState) -> Void
    func onDiscarded(source: Actor, battleState: BattleState) -> Void
}

extension CardStrategy {
    func instance(uuid: UUID = UUID()) -> Card {
        return Card(uuid: uuid, card: self)
    }
}


class Card: Codable {
    
    let uuid: UUID
    let card: CardStrategy
    
    var cardNumber: Int { get { self.card.cardNumber }}
    var name: String { get { self.card.name }}
    var requiresSingleTarget: Bool { get { self.card.requiresSingleTarget }}
    var cost: Int { get { self.card.cost }}
    var cardText: String { get { self.card.cardText }}
    
    init(uuid: UUID, card: CardStrategy) {
        self.uuid = uuid
        self.card = card
    }
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) -> Void {
        self.card.resolve(cardUuid: self.uuid, source: source, battleState: battleState, target: target)
    }
    
    func onDrawn(source: Actor, battleState: BattleState) -> Void {
        self.card.onDrawn(source: source, battleState: battleState)
    }
    
    func onDiscarded(source: Actor, battleState: BattleState) -> Void {
        self.card.onDiscarded(source: source, battleState: battleState)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case cardNumber
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(card.cardNumber, forKey: .cardNumber)
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(UUID.self, forKey: .uuid)
        let number = try values.decode(Int.self, forKey: .cardNumber)
        
        switch number {
        case 1: self.card = CardStrike()
        case 5: self.card = CardDefend()
        default:
            throw NSError.init(domain: "CardDeserializeError", code: 0, userInfo: nil)
        
        }
        
    }

}



