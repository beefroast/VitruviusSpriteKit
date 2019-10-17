//
//  ICard.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

struct CardAttributes: OptionSet, Codable {
    let rawValue: Int
    static let attack = CardAttributes(rawValue: 1 << 0)
    static let spell = CardAttributes(rawValue: 1 << 1)
    static let melee = CardAttributes(rawValue: 1 << 2)
    static let ranged = CardAttributes(rawValue: 1 << 3)
    static let buff = CardAttributes(rawValue: 1 << 4)
    static let debuff = CardAttributes(rawValue: 1 << 5)
    static let defence = CardAttributes(rawValue: 1 << 6)
    static let heal = CardAttributes(rawValue: 1 << 7)
    static let summons = CardAttributes(rawValue: 1 << 8)
    static let potion = CardAttributes(rawValue: 1 << 9)
    static let status = CardAttributes(rawValue: 1 << 10)
    static let curse = CardAttributes(rawValue: 1 << 11)
}




enum CardRarity: Int, Codable {
    case basic
    case common
    case uncommon
    case rare
    case mythic
}



protocol CardStrategy {
    
    var cardNumber: Int { get }
    var name: String { get }
    var requiresSingleTarget: Bool { get }
    var cost: Int { get set }
    var cardText: String { get }
    var rarity: CardRarity { get }
    var attributes: CardAttributes { get }
    
    func textFor(card: Card) -> String
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) -> Void
    func onDrawn(card: Card, source: Actor, battleState: BattleState) -> Void
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) -> Void
}

extension CardStrategy {
    func instance(level: Int = 0, uuid: UUID = UUID()) -> Card {
        return Card(uuid: uuid, level: level, card: self)
    }
}


class Card: Codable {
    
    let uuid: UUID
    var level: Int
    let card: CardStrategy
    
    var cardNumber: Int { get { self.card.cardNumber }}
    var name: String { get { self.card.name }}
    var requiresSingleTarget: Bool { get { self.card.requiresSingleTarget }}
    var cost: Int { get { self.card.cost }}
    var cardText: String { get { self.card.cardText }}
    
    init(uuid: UUID, level: Int, card: CardStrategy) {
        self.uuid = uuid
        self.level = level
        self.card = card
    }
    
    func getText() -> String {
        return self.card.textFor(card: self)
    }
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) -> Void {
        self.card.resolve(card: self, source: source, battleState: battleState, target: target)
    }
    
    func onDrawn(source: Actor, battleState: BattleState) -> Void {
        self.card.onDrawn(card: self, source: source, battleState: battleState)
    }
    
    func onDiscarded(source: Actor, battleState: BattleState) -> Void {
        self.card.onDiscarded(card: self, source: source, battleState: battleState)
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case level
        case cardNumber
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(level, forKey: .level)
        try container.encode(card.cardNumber, forKey: .cardNumber)
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(UUID.self, forKey: .uuid)
        level = try values.decode(Int.self, forKey: .level)
        let number = try values.decode(Int.self, forKey: .cardNumber)
        
        switch number {
        case 1: self.card = CardStrike()
        case 2: self.card = CardMistForm()
        case 3: self.card = CardPierce()
        case 4: self.card = CardDrain()
        case 5: self.card = CardDefend()
        case 6: self.card = CardRecall()
        case 7: self.card = CardFireball()
        default:
            throw NSError.init(domain: "CardDeserializeError", code: 0, userInfo: nil)
        
        }
        
    }

}



