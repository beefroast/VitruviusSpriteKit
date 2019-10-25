//
//  Mission.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

class Mission {
    
    let name: String
    let totalDays: Int
    
    init(name: String, totalDays: Int) {
        self.name = name
        self.totalDays = totalDays
    }
    
    func getBattleState(gameState: GameState) -> BattleState {
        
        let player = gameState.playerData.newActor()
        
        let goomba = Enemy(
             uuid: UUID(),
             name: "Goomba",
             faction: .enemies,
             body: Body(block: 0, hp: 40, maxHp: 40),
             cardZones: CardZones(
                hand: Hand.newEmpty(),
                drawPile: DrawPile.newEmpty(),
                 discard: DiscardPile()
             ),
             enemyStrategy: CrabEnemyStrategy()
         )
         
         let koopa = Enemy(
             uuid: UUID(),
             name: "Koopa",
             faction: .enemies,
             body: Body(block: 0, hp: 40, maxHp: 40),
             cardZones: CardZones(
                hand: Hand.newEmpty(),
                drawPile: DrawPile.init(cards: [
                    CSStrike().instance(),
                    CSDefend().instance()
                ]),
                 discard: DiscardPile()
             ),
             enemyStrategy: SuccubusEnemyStrategy()
         )
        
        let battleState = BattleState.init(
            player: player,
            allies: [],
            enemies: [goomba, koopa],
            eventHandler: EventHandler(
                uuid: UUID(),
                eventStack: StackQueuePrinter<Event>(),
                effectList: [
                    EventPrinterEffect.init().withWrapper(uuid: UUID())
                ]
            ),
            rng: gameState.random
        )
                
        
        battleState.eventHandler.push(events: [
            Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: player.uuid, cardsDrawn: 5).withWrapper(uuid: UUID())),
            Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: goomba.uuid, cardsDrawn: 0).withWrapper(uuid: UUID())),
            Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: koopa.uuid, cardsDrawn: 1).withWrapper(uuid: UUID()))
        ])
        
        return battleState
    }
    
}
