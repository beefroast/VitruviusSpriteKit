//
//  FaithCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CSDrain: CardStrategy {

    let cardNumber: Int = 4
    
    var name: String = "Drain"
    var cardText: String { get { return "Attack for 6. Gain life equal to the hp lost this way." }}
    var requiresSingleTarget: Bool = true
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .spell]
    let classes: CardClasses = .faith
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func costFor(card: Card) -> Int { return 1 }
    
    func resolve(card: Card, source: Actor, gameState: GameState, target: Actor?) {

        guard let target = target?.uuid else {
            return
        }
        
//        battleState.eventHandler.push(events: [
//            
//            // Listen for damage done by this source, and gain that much life
//            Event.addEffect(
//                DrainEffect.init(
//                    ownerUuid: source.uuid,
//                    sourceUuid: card.uuid
//                ).withWrapper(uuid: UUID())
//            ),
//                
//            // Attack for 6
//            Event.attack(AttackEvent.init(
//                sourceUuid: card.uuid,
//                sourceOwner: source.uuid,
//                targets: [target],
//                amount: 6
//            )),
//            
//            // Discard this card
//            Event.discardCard(CardEvent.init(
//                actorUuid: source.uuid,
//                cardUuid: card.uuid
//            )),
//            
//        ])
        
    }

    func onDrawn(card: Card, source: Actor, gameState: GameState) {
    }
    
    func onDiscarded(card: Card, source: Actor, gameState: GameState) {
    }
    
    
}

