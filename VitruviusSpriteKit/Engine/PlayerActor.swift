//
//  PlayerActor.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

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
