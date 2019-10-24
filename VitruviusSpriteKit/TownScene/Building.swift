//
//  Building.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 21/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

class Building: Codable {
    
    let type: BuildingType
    let level: Int
    let daysUntilFinished: Int
    
    init(type: BuildingType,
         level: Int,
         daysUntilFinished: Int) {
        self.type = type
        self.level = level
        self.daysUntilFinished = daysUntilFinished
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case type
        case level
        case daysUntilFinished
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.level = try values.decode(Int.self, forKey: .level)
        self.daysUntilFinished = try values.decode(Int.self, forKey: .daysUntilFinished)
        let typeName = try values.decode(String.self, forKey: .type)
        switch typeName {
        case "Tavern": self.type = BTTavern()
        case "Forge": self.type = BTForge()
        default: throw NSError(domain: "Oh no", code: 666, userInfo: nil)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.level, forKey: .level)
        try container.encode(self.daysUntilFinished, forKey: .daysUntilFinished)
        try container.encode(self.type.name, forKey: .type)
    }
    
}

protocol BuildingType: Codable {
    var name: String { get }
    var cost: Int { get }
    var description: String { get }
    var maxLevel: Int { get }
    func daysToUpdateFor(level: Int) -> Int
}

extension BuildingType {
    func newInstance() -> Building {
        return Building(
            type: self,
            level: 0,
            daysUntilFinished: self.daysToUpdateFor(level: 0)
        )
    }
}

// TAVERN - Lets you undertake quests and sleep for HP.
// JOINERY - Lets you build more buildings.
// FORGE - Lets you upgrade cards.
// ALCHEMIST - Lets you buy potions.
// CHAPEL - Lets you donate cards (effectively the chapel from dominion).
// SHOP - Lets you buy cards.
// BESTIARY - Lets you do autopsies on enemies to get their cards.
// ARENA - Lets you fight other players

class BTTavern: BuildingType {
    
    var name: String { get { return "Tavern" }}
    var cost: Int { get { return 0 }}
    var description: String { get { return "The tarvern allows you to undertake quests and sleep to regain hp." }}
    var maxLevel: Int { get { return 5 }}
    
    func daysToUpdateFor(level: Int) -> Int {
        switch level {
        case 0: return 10
        case 1: return 3
        case 2: return 4
        case 3: return 5
        case 4: return 6
        default: return 7
        }
    }
}

class BTJoinery: BuildingType {
    
    var name: String { get { return "Joinery" }}
    var cost: Int { get { return 0 }}
    var description: String { get { return "The joinery allows you to build new buildings" }}
    var maxLevel: Int { get { return 5 }}
    
    func daysToUpdateFor(level: Int) -> Int {
        switch level {
        case 0: return 10
        case 1: return 3
        case 2: return 4
        case 3: return 5
        case 4: return 6
        default: return 7
        }
    }
}

class BTForge: BuildingType {
    
    var name: String { get { return "Forge" }}
    var cost: Int { get { return 40 }}
    var description: String { get { return "Allows you to leave cards to be upgraded." }}
    var maxLevel: Int { get { return 5 }}

    func daysToUpdateFor(level: Int) -> Int {
        switch level {
        case 0: return 8
        case 1: return 9
        case 2: return 10
        case 3: return 11
        case 4: return 12
        default: return 13
        }
    }
}


