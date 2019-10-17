//
//  NeutralCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardStrike: CardStrategy, Codable {

    let cardNumber: Int = 1
    let name =  "Strike"
    var cardText: String { get { return "Attack for 6." }}
    let requiresSingleTarget: Bool = true
    var cost: Int = 1
    var level: Int = 0
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .melee]
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        guard let target = target else {
            return
        }
        
        
        battleState.eventHandler.push(events: [
        
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.attack(
                 AttackEvent(
                    sourceUuid: card.uuid,
                     sourceOwner: source.uuid,
                     targets: [target.uuid],
                     amount: 6
                 )
             )
             
        ])
        
        
 
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}



class CardDefend: CardStrategy {
    
    let cardNumber: Int = 5
    
    let name =  "Defend"
    var cardText: String { get { return "Block for 5." }}
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.defence]
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.willGainBlock(UpdateAmountEvent.init(targetActorUuid: source.uuid, sourceUuid: card.uuid, amount: 5))
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}


class CardHealthPotion: CardStrategy {
    
    let cardNumber: Int = 8
    let name =  "Health Potion"
    let cardText: String = "Gain 10 hp. Expend Health Potion."
    var requiresSingleTarget: Bool = false
    var cost: Int = 0
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.potion, .heal]
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.expendCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.willGainHp(UpdateAmountEvent.init(targetActorUuid: source.uuid, sourceUuid: card.uuid, amount: 10)),
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}
