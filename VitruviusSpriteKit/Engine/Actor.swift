//
//  Actor.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

// TODO: Need to be able to serialize actors
class Actor: IDamagable, ICardPlayer, Codable {
    
    let uuid: UUID
    let name: String
    let faction: Faction
    var body: Body
    var cardZones: CardZones

    
    init(uuid: UUID, name: String, faction: Faction, body: Body, cardZones: CardZones) {
        self.uuid = uuid
        self.name = name
        self.faction = faction
        self.body = body
        self.cardZones = cardZones
    }
}

class Player: Actor {
    
    var currentMana: Int
    var maxMana: Int
    
    init(uuid: UUID, name: String, faction: Faction, body: Body, cardZones: CardZones, currentMana: Int, maxMana: Int) {
        self.currentMana = currentMana
        self.maxMana = maxMana
        super.init(uuid: uuid, name: name, faction: faction, body: body, cardZones: cardZones)
    }
    
    private enum CodingKeys: String, CodingKey {
        case currentMana
        case maxMana
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.currentMana = try values.decode(Int.self, forKey: .currentMana)
        self.maxMana = try values.decode(Int.self, forKey: .maxMana)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.currentMana, forKey: .currentMana)
        try container.encode(self.maxMana, forKey: .maxMana)
    }
}

// This needs to be serializable
class PlayerData: Codable {
    
    let uuid: UUID
    let decklist: [Card]   // Cards need to be duplictable
    var daysUntilNextBoss: Int
    var bossesKilled: Int
    var nextBoss: String
    let currentXp: Int
    var currentGold: Int
    var currentHp: Int
    var maxHp: Int
    let name: String
    let characterClass: CharacterClass
    
    init(
        uuid: UUID,
        decklist: [Card],
        daysUntilNextBoss: Int,
        bossesKilled: Int,
        nextBoss: String,
        currentXp: Int,
        currentGold: Int,
        currentHp: Int,
        maxHp: Int,
        name: String,
        characterClass: CharacterClass) {
        
        self.uuid = uuid
        self.decklist = decklist
        self.daysUntilNextBoss = daysUntilNextBoss
        self.bossesKilled = bossesKilled
        self.nextBoss = nextBoss
        self.currentXp = currentXp
        self.currentGold = currentGold
        self.currentHp = currentHp
        self.maxHp = maxHp
        self.name = name
        self.characterClass = characterClass
    }
    
    
    func newActor() -> Player {
        
        let decklist = self.decklist.map({ $0.duplicate() })
        
        return Player(
            uuid: self.uuid,
            name: self.name,
            faction: .player,
            body: Body(block: 0, hp: self.currentHp, maxHp: self.maxHp),
            cardZones: CardZones(
                hand: Hand.init(),
                drawPile: DrawPile.init(cards: decklist),
                discard: DiscardPile.init()),
            currentMana: 0,
            maxMana: 3
        )
    }
    
    static func newPlayerFor(name: String, characterClass: CharacterClass) -> PlayerData {
        return PlayerData.init(
            uuid: UUID(),
            decklist: starterDeckFor(characterClass: characterClass),
            daysUntilNextBoss: 30,
            bossesKilled: 0,
            nextBoss: "Goblin Horde",
            currentXp: 0,
            currentGold: 100,
            currentHp: 70,
            maxHp: 70,
            name: name,
            characterClass: characterClass
        )
    }
    
    static func starterDeckFor(characterClass: CharacterClass) -> [Card] {
    
        var starterDeck = [
            CSStrike().instance(),
            CSStrike().instance(),
            CSStrike().instance(),
            CSStrike().instance(),
            CSDefend().instance(),
            CSDefend().instance(),
            CSDefend().instance(),
            CSDefend().instance(),
        ]
        
        switch characterClass {
        
        case .wizard:
            starterDeck.append(contentsOf: [
                CSFireball().instance(),
                CSRecall().instance()
            ])
            
        default:
            // TODO: Starter decks for each class
            break
        }
        
        return starterDeck
    }
    
    
    
}


// Flow of game

// Be offered a set of encounters
// Choose an encounter
