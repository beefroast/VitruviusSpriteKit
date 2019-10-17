//
//  SharpCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardRecall : CardStrategy {
    
    let cardNumber: Int = 6
    
    var name: String = "Recall"
    var cardText: String { get { return "Draw 3 cards." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 0
    
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = .spell
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.willDrawCards(DrawCardsEvent.init(actorUuid: source.uuid, amount: 3))
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}

class CardFireball: CardStrategy {
    
    let cardNumber: Int = 7
    
    var name: String = "Fireball"
    var cardText: String { get { return "Attack each enemy for 8." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 2
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .spell]
        
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        let targets = battleState.getAllOpponentActors(faction: source.faction).map({ $0.uuid })
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.attack(AttackEvent.init(sourceUuid: card.uuid, sourceOwner: source.uuid, targets: targets, amount: 8))
        ])

    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
    
}
