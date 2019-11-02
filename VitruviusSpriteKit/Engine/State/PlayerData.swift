//
//  PlayerData.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class PlayerData: Codable {
    
    let uuid: UUID
    var decklist: [Card]  
    var currentGold: Int
    var currentHp: Int
    var maxHp: Int
    let name: String
    let characterClass: CharacterClass
    var currentLevel: Int
    
    init(
        uuid: UUID,
        decklist: [Card],
        currentGold: Int,
        currentHp: Int,
        maxHp: Int,
        name: String,
        characterClass: CharacterClass,
        currentLevel: Int) {
        
        self.uuid = uuid
        self.decklist = decklist
        self.currentGold = currentGold
        self.currentHp = currentHp
        self.maxHp = maxHp
        self.name = name
        self.characterClass = characterClass
        self.currentLevel = currentLevel
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
            currentGold: 100,
            currentHp: 70,
            maxHp: 70,
            name: name,
            characterClass: characterClass,
            currentLevel: 0
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


