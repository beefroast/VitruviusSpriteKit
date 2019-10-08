//
//  SharpCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardRecall : ICard {
    
    let cardNumber: Int = 6
    
    var uuid: UUID = UUID()
    var name: String = "Recall"
    var cardText: String { get { return "Draw 3 cards." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 0
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid)),
            Event.willDrawCards(DrawCardsEvent.init(actorUuid: source.uuid, amount: 3))
        ])
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}

class CardFireball: ICard {
    
    let cardNumber: Int = 7
    
    var uuid: UUID = UUID()
    var name: String = "Fireball"
    var cardText: String { get { return "Attack each enemy for 8." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 2
        
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        let targets = battleState.getAllOpponentActors(faction: source.faction).map({ $0.uuid })
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid)),
            Event.attack(AttackEvent.init(sourceUuid: self.uuid, sourceOwner: source.uuid, targets: targets, amount: 8))
        ])

    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
}
