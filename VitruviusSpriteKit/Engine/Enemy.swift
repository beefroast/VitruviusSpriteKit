//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 2/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class Enemy: Actor {

    func onBattleBegin(state: BattleState) -> Void {
        // TODO: Push all the prebattle card effects on the stack...
        // This gives the enemy a chance to pre-buff before a battle, gaining
        // armour or something like that...
    }

    func planTurn(state: BattleState) -> Event {
        
        // Can't modify the effects list stack here, so we need to
        // enqueue a plan event...
        // This is fine because we can listen for that event anyway...
        
        return Event.onEnemyPlannedTurn(
            EnemyTurnEffect(
                enemyUuid: self.uuid,
                name: "\(self.name)'s turn",
                events: []
            )
        )
    }
    
//    private enum CodingKeys: String, CodingKey {
//        case currentMana
//        case maxMana
//    }
//
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        self.currentMana = try values.decode(Int.self, forKey: .currentMana)
//        self.maxMana = try values.decode(Int.self, forKey: .maxMana)
//        try super.init(from: decoder)
//    }
//
//    override func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.currentMana, forKey: .currentMana)
//        try container.encode(self.maxMana, forKey: .maxMana)
//    }
}

class EnemyTurnEffect: HandleEffectStrategy {
    
    let enemyUuid: UUID
    var events: [Event]
    
    init(enemyUuid: UUID, name: String, events: [Event]) {
        self.enemyUuid = enemyUuid
        self.events = events
        super.init(identifier: .enemyTurn, effectName: name)
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case enemyUuid
        case events
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.enemyUuid = try values.decode(UUID.self, forKey: .enemyUuid)
        self.events = try values.decode([Event].self, forKey: .events)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.enemyUuid, forKey: .enemyUuid)
        try container.encode(self.events, forKey: .events)
    }
    
    override func handle(event: Event, state: BattleState, effectUuid: UUID) -> Bool {
        switch event {
            
        case .onEnemyDefeated(let e):
            
            // Remove this event if the enemy is defeated...
            return e.actorUuid == self.enemyUuid
            
        case .onTurnBegan(let e):
            
            // When our turn begins...
            guard e.actorUuid == self.enemyUuid else {
                return false
            }
            
            // Find the enemy
            guard let enemy = state.actorWith(uuid: enemyUuid) as? Enemy else {
                return true
            }
            
            state.eventHandler.push(events:
                
                // Do our planned turn
                events + [
                    
                // Plan our next turn
                enemy.planTurn(state: state),
                
                //End our turn
                Event.onTurnEnded(ActorEvent.init(actorUuid: enemyUuid))
            
            ])
            
            // Remove this listener
            return true
            
        default:
            return false
        }
    }
}

class TestEnemy: Enemy {
    override func planTurn(state: BattleState) -> Event {
        
        let rand = Int.random(in: (0...2))
        
        
        switch rand {
        case 2:
            return Event.onEnemyPlannedTurn(
                EnemyTurnEffect.init(
                    enemyUuid: self.uuid,
                    name: "\(self.name)'s turn",
                    events: [
                        Event.attack(
                            AttackEvent.init(
                                sourceUuid: self.uuid,
                                sourceOwner: self.uuid,
                                targets: [state.getAllActors(faction: .player).first?.uuid].compactMap({ return $0 }),
                                amount: 18
                            )
                        )
                    ])
            )
        default:
            return Event.onEnemyPlannedTurn(
                EnemyTurnEffect.init(
                    enemyUuid: self.uuid,
                    name: "\(self.name)'s turn",
                    events: [
                        Event.attack(
                            AttackEvent.init(
                                sourceUuid: self.uuid,
                                sourceOwner: self.uuid,
                                targets: [state.getAllActors(faction: .player).first?.uuid].compactMap({ return $0 }),
                                amount: 12
                            )
                        ),
                        Event.willGainBlock(
                            UpdateAmountEvent.init(
                                targetActorUuid: self.uuid,
                                sourceUuid: self.uuid,
                                amount: 6
                            )
                        )
                    ])
            )
        }
        
        
        
    }
}

