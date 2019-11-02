//
//  SharpCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CSRecall : CardStrategy {
    
    let cardNumber: Int = 6
    
    var name: String = "Recall"
    var cardText: String { get { return "Draw 3 cards." }}
    var requiresSingleTarget: Bool = false
    
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = .spell
    let classes: CardClasses = .sharp
    
    func costFor(card: Card) -> Int { return 0 }
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func resolve(card: Card, source: Actor, gameState: GameState, target: Actor?) {
//        battleState.eventHandler.push(events: [
//            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
//            Event.willDrawCards(DrawCardsEvent.init(actorUuid: source.uuid, amount: 3))
//        ])
    }
    
    func onDrawn(card: Card, source: Actor, gameState: GameState) {}
    func onDiscarded(card: Card, source: Actor, gameState: GameState) {}
}

class CSFireball: CardStrategy {
    
    let cardNumber: Int = 7
    
    var name: String = "Fireball"
    var cardText: String { get { return "Channel. Then deal 8 damage to each enemy." }}
    var requiresSingleTarget: Bool = false

    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .spell]
    let classes: CardClasses = .sharp
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func costFor(card: Card) -> Int { return card.level > 0 ? 4 : 3 }
        
    func resolve(card: Card, source: Actor, gameState: GameState, target: Actor?) {
        
        guard let battleState = gameState.currentBattle else {
            return
        }
        
//        battleState.eventHandler.push(event: Event.addEffect(Effect.))
        
        
//        let targets = battleState.getAllOpponentActors(faction: source.faction).map({ $0.uuid })
//        
//        battleState.eventHandler.push(events: [
//            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
//            Event.attack(AttackEvent.init(sourceUuid: card.uuid, sourceOwner: source.uuid, targets: targets, amount: 8))
//        ])

    }
    
    func onDrawn(card: Card, source: Actor, gameState: GameState) {}
    func onDiscarded(card: Card, source: Actor, gameState: GameState) {}
    
}
