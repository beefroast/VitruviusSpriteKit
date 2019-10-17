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
class PlayerData {
    
    let uuid: UUID
    let decklist: [Card]   // Cards need to be duplictable
    let currentXp: Int
    let currentGold: Int
    let currentHp: Int
    let maxHp: Int
    let name: String
    
    init(
        uuid: UUID,
        decklist: [Card],
        currentXp: Int,
        currentGold: Int,
        currentHp: Int,
        maxHp: Int,
        name: String) {
        
        self.uuid = uuid
        self.decklist = decklist
        self.currentXp = currentXp
        self.currentGold = currentGold
        self.currentHp = currentHp
        self.maxHp = maxHp
        self.name = name
    }
    
    func newActor() -> Player {
        return Player(
            uuid: self.uuid,
            name: self.name,
            faction: .player,
            body: Body(block: 0, hp: self.currentHp, maxHp: self.maxHp),
            cardZones: CardZones(
                hand: Hand.init(),
                drawPile: DrawPile.init(cards: self.decklist),
                discard: DiscardPile.init()),
            currentMana: 0,
            maxMana: 3
        )
    }
    
    func paladinStarter(name: String) -> PlayerData {
        return PlayerData(
            uuid: UUID(),
            decklist: [
                CSStrike().instance(),
                CSStrike().instance(),
                CSStrike().instance(),
                CSStrike().instance(),
                CSDefend().instance(),
                CSDefend().instance(),
                CSDefend().instance(),
                CSDefend().instance(),
                CSDefend().instance(),
                CSDrain().instance(),
            ],
            currentXp: 0,
            currentGold: 100,
            currentHp: 70,
            maxHp: 70,
            name: name
        )
    }
    
}


