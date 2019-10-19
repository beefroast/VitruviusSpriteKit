//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 2/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class Enemy: Actor {

    let enemyStrategy: EnemyStrategy
    
    init(uuid: UUID, name: String, faction: Faction, body: Body, cardZones: CardZones, enemyStrategy: EnemyStrategy) {
        self.enemyStrategy = enemyStrategy
        super.init(uuid: uuid, name: name, faction: faction, body: body, cardZones: cardZones)
    }
    
    func onBattleBegin(state: BattleState) -> Void {
        self.enemyStrategy.onBattleBegan(enemy: self, state: state)
    }

    func planTurn(state: BattleState) -> Event {
        return self.enemyStrategy.planTurn(enemy: self, state: state)
    }
    
    // Convenience methods
    func planAttack(state: BattleState, amount: Int) -> Event {
        return Event.onEnemyPlannedTurn(
            EnemyTurnEffect.init(
                enemyUuid: self.uuid,
                name: "\(self.name)'s turn",
                events: [
                    Event.attack(AttackEvent.init(
                        sourceUuid: self.uuid,
                        sourceOwner: self.uuid,
                        targets: [state.getAllActors(faction: .player).first?.uuid].compactMap({ return $0 }),
                        amount: amount
                    ))
                ]
            )
        )
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case strategyName
        case strategyData
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let strategyName = try values.decode(String.self, forKey: .strategyName)
        
        switch strategyName {
        
        case "crab":
            self.enemyStrategy = try values.decode(CrabEnemyStrategy.self, forKey: .strategyData)
        
        default:
            throw NSError.init(domain: "TODO Btetter error", code: 0, userInfo: nil)
        }
        
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.enemyStrategy.getStrategyName(), forKey: .strategyName)
        try container.encode(self.enemyStrategy, forKey: .strategyData)
    }
    
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




class EnemyStrategy: Codable {
    func getStrategyName() -> String { return "" }
    func planTurn(enemy: Enemy, state: BattleState) -> Event { fatalError("Must be overriden") }
    func onBattleBegan(enemy: Enemy, state: BattleState) -> Void {}
}

class CrabEnemyStrategy: EnemyStrategy {
    override func getStrategyName() -> String { return "crab" }
    override func planTurn(enemy: Enemy, state: BattleState) -> Event {
        return Event.onEnemyPlannedTurn(
            EnemyTurnEffect.init(
                enemyUuid: enemy.uuid,
                name: "\(enemy.name)'s turn",
                events: [
                    Event.attack(AttackEvent.init(
                        sourceUuid: enemy.uuid,
                        sourceOwner: enemy.uuid,
                        targets: [state.getAllActors(faction: .player).first?.uuid].compactMap({ return $0 }),
                        amount: 6
                    ))
                ]
            )
        )
    }
    
    func with(challengeRating: Int, rng: SeededRandomNumberGenerator) -> Enemy {
        // TODO: We can adjust the difficulty of the crab in here, giving it
        // more health or whatever.
        return Enemy(
            uuid: UUID(),
            name: "Crab",
            faction: .enemies,
            body: Body(block: 0, hp: 10, maxHp: 10),
            cardZones: CardZones.newEmpty(),
            enemyStrategy: self
        )
    }
}

class SuccubusEnemyStrategy: EnemyStrategy {
    override func getStrategyName() -> String { return "succubus" }
    override func planTurn(enemy: Enemy, state: BattleState) -> Event {
        return enemy.planAttack(state: state, amount: 10)
    }
    override func onBattleBegan(enemy: Enemy, state: BattleState)  {
        
    }
}





