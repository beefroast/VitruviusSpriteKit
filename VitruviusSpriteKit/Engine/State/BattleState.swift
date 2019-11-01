////
////  BattleState.swift
////  Vitruvius
////
////  Created by Benjamin Frost on 28/9/19.
////  Copyright © 2019 Benjamin Frost. All rights reserved.
////
//
import Foundation



class BattleState: Codable {
    
    var player: Player
    var allies: [Actor]
    var enemies: [Enemy]
    var eventHandler: EventQueueHandler
    var rng: RandomnessSource
    
    init(player: Player, allies: [Actor], enemies: [Enemy], eventHandler: EventQueueHandler, rng: RandomnessSource) {
        self.player = player
        self.allies = allies
        self.enemies = enemies
        self.eventHandler = eventHandler
        self.rng = rng
    }
    
    func getAllActors() -> [Actor] {
        return [player] + allies + enemies
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
    
    func actorWith(uuid: UUID) -> Actor? {
        return ([player] + allies + enemies).first { (a) -> Bool in
            a.uuid == uuid
        }
    }
    
    func descriptionForActorWith(uuid: UUID) -> String {
        return self.actorWith(uuid: uuid)?.name ?? uuid.uuidString
    }
    
    func popNext() -> Void {
        
    }
    
    static func newInstance(randomSource: RandomnessSource, player: Player, enemies: [Enemy]) -> BattleState {
        
        return BattleState.init(
            player: player,
            allies: [],
            enemies: enemies,
            eventHandler: EventQueueHandler.init(
                eventQueue: PriorityQueue.init().withInserted(element: Event.onBattleBegan),
                effectList: PriorityQueue.init()
        ), rng: randomSource)
    }
}


