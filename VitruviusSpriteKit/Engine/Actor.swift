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


