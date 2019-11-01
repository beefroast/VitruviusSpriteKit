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

    func planTurn(state: BattleState)  {
        self.enemyStrategy.planTurn(enemy: self, state: state)
    }
    
    // Convenience methods
    func planAttack(state: BattleState, amount: Int) -> Event {
        fatalError()
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




class EnemyStrategy: Codable {
    func getStrategyName() -> String { return "" }
    func planTurn(enemy: Enemy, state: BattleState) {  }
    func onBattleBegan(enemy: Enemy, state: BattleState) -> Void {}
}

class CrabEnemyStrategy: EnemyStrategy {
    override func getStrategyName() -> String { return "crab" }
    
    override func planTurn(enemy: Enemy, state: BattleState) {
        _ = state.eventHandler.push(event:
            Event.attack(AttackEvent.init(sourceUuid: enemy.uuid, sourceOwner: enemy.uuid, targets: [state.player.uuid], amount: 5))
            , priority: 10)
    }
    
    func with(challengeRating: Int, rng: RandomIntegerGenerator) -> Enemy {
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







