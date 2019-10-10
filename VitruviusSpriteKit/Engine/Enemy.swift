//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 2/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class Enemy: Actor {

    let preBattleCards: [ICard]

    init(uuid: UUID, name: String, faction: Faction, body: Body, cardZones: CardZones, preBattleCards: [ICard]) {
        self.preBattleCards = preBattleCards
        super.init(uuid: uuid, name: name, faction: faction, body: body, cardZones: cardZones)
    }

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
                uuid: UUID(),
                enemyUuid: self.uuid,
                name: "\(self.name)'s turn",
                events: []
            )
        )
    }
}

class EnemyTurnEffect: IEffect, Codable {

    var uuid: UUID
    var enemyUuid: UUID
    var effectName: String
    var events: [Event]
    
    init(uuid: UUID, enemyUuid: UUID, name: String, events: [Event]) {
        self.uuid = uuid
        self.enemyUuid = enemyUuid
        self.effectName = name
        self.events = events
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
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
                    uuid: UUID(),
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
                    ]
                )
            )
        default:
            return Event.onEnemyPlannedTurn(
                EnemyTurnEffect.init(
                    uuid: UUID(),
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
                            UpdateBodyEvent.init(
                                targetActorUuid: self.uuid,
                                sourceUuid: self.uuid,
                                amount: 6
                            )
                        )
                    ]
                )
            )
        }
        
        
        
    }
}

