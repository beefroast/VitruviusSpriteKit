////
////  BattleState.swift
////  Vitruvius
////
////  Created by Benjamin Frost on 28/9/19.
////  Copyright © 2019 Benjamin Frost. All rights reserved.
////
//
import Foundation


enum Faction {
    case player
    case allies
    case goodGuys
    case enemies
}

class BattleState {
    
    var player: Actor
    var allies: [Actor]
    var enemies: [Enemy]
    var eventHandler: EventHandler
    
    init(player: Actor, allies: [Actor], enemies: [Enemy], eventHandler: EventHandler) {
        self.player = player
        self.allies = allies
        self.enemies = enemies
        self.eventHandler = eventHandler
    }
    
    func getAllActors(faction: Faction) -> [Actor] {
        switch faction {
        case .player: return [player]
        case .allies: return allies
        case .goodGuys: return [player] + allies
        case .enemies: return enemies
        }
    }
    
    func getAllOpponentActors(faction: Faction) -> [Actor] {
        switch faction {
        case .player, .allies, .goodGuys: return self.getAllActors(faction: .enemies)
        case .enemies: return self.getAllActors(faction: .goodGuys)
        }
    }
    
    func popNext() -> Void {
        _ = self.eventHandler.popAndHandle(battleState: self)
    }
}


