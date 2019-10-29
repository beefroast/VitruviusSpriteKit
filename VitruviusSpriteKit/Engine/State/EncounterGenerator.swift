//
//  EncounterGenerator.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 27/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


enum Encounter: Codable {
    
    case battle([Enemy])
    
    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        
        switch type {
        
        case "battle":
            let enemies = try values.decode([Enemy].self, forKey: .data)
            self = .battle(enemies)
            
        default:
            throw NSError.init()

        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
            
        switch self {
            
        case .battle(let enemies):
            try container.encode("battle", forKey: .type)
            try container.encode(enemies, forKey: .data)
            
        default:
            break
                
        }   
    }
}



class EncounterGenerator {
    
    func generateEncounterFor(level: Int) -> Encounter {
        
        // For now, just generate a dummy battle encounter
        
        return Encounter.battle([
            Enemy(
                uuid: UUID(),
                name: "Crab",
                faction: .enemies,
                body: Body(block: 0, hp: 10, maxHp: 10),
                cardZones: CardZones.newEmpty(),
                enemyStrategy: CrabEnemyStrategy()
            )
        ])
        
    }
    
}
