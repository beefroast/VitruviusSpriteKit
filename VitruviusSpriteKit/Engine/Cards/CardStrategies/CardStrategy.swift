//
//  ICard.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

struct CardClasses: OptionSet, Codable {
    
    let rawValue: Int
    
    static let neutral = CardClasses(rawValue: 1 << 0)
    static let charm = CardClasses(rawValue: 1 << 1)
    static let guile = CardClasses(rawValue: 1 << 2)
    static let might = CardClasses(rawValue: 1 << 3)
    static let faith = CardClasses(rawValue: 1 << 4)
    static let sharp = CardClasses(rawValue: 1 << 5)
}

enum CharacterClass: Int, Codable {
    
    case swashbucker    = 6
    case barbarian      = 10
    case priest         = 18
    case wizard         = 34
    case scoundrel      = 12
    case monk           = 20
    case thief          = 36
    case paladin        = 24
    case spellsword     = 40
    case sage           = 48
    
    func allowedCardClasses() -> CardClasses {
        return CardClasses.init(rawValue: self.rawValue + 1)
    }
    
    static func asList() -> [CharacterClass] {
        return [
        .swashbucker,
        .barbarian,
        .priest,
        .wizard,
        .scoundrel,
        .monk,
        .thief,
        .paladin,
        .spellsword,
        .sage
        ]
    }
}




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
    
    static var none: CardAttributes = []
    
    static var desirableCards: CardAttributes = [
        .attack, .spell, .melee, .ranged, .buff, .debuff, .defence, .heal, .summons, .potion
    ]
    
    static var nonRewardTypes: CardAttributes = [.status, .curse]
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
    var rarity: CardRarity { get }
    var attributes: CardAttributes { get }
    var classes: CardClasses { get }
    
    func textFor(card: Card) -> String
    func costFor(card: Card) -> Int
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
    let strategy: CardStrategy
    
    var cardNumber: Int { get { self.strategy.cardNumber }}
    var name: String { get { self.strategy.name }}
    var requiresSingleTarget: Bool { get { self.strategy.requiresSingleTarget }}
    var cost: Int { get { self.strategy.costFor(card: self) }}
    var cardText: String { get { self.strategy.textFor(card: self) }}
    
    init(uuid: UUID, level: Int, card: CardStrategy) {
        self.uuid = uuid
        self.level = level
        self.strategy = card
    }
    
    func getText() -> String {
        return self.strategy.textFor(card: self)
    }
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) -> Void {
        self.strategy.resolve(card: self, source: source, battleState: battleState, target: target)
    }
    
    func onDrawn(source: Actor, battleState: BattleState) -> Void {
        self.strategy.onDrawn(card: self, source: source, battleState: battleState)
    }
    
    func onDiscarded(source: Actor, battleState: BattleState) -> Void {
        self.strategy.onDiscarded(card: self, source: source, battleState: battleState)
    }
    
    func duplicate(uuid: UUID = UUID()) -> Card {
        return Card(uuid: uuid, level: self.level, card: self.strategy)
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
        try container.encode(strategy.cardNumber, forKey: .cardNumber)
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(UUID.self, forKey: .uuid)
        level = try values.decode(Int.self, forKey: .level)
        let number = try values.decode(Int.self, forKey: .cardNumber)
        
        switch number {
        case 1: self.strategy = CSStrike()
        case 4: self.strategy = CSDrain()
        case 5: self.strategy = CSDefend()
        case 6: self.strategy = CSRecall()
        case 7: self.strategy = CSFireball()
        default:
            throw NSError.init(domain: "CardDeserializeError", code: 0, userInfo: nil)
        
        }
        
    }

}



