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
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .melee]
    let classes: CardClasses = .neutral
    
    func textFor(card: Card) -> String {
        return "Attack for \(card.level > 0 ? "9" : "6")"
    }
    
    func costFor(card: Card) -> Int { return 1 }
    
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
                     amount: card.level > 0 ? 9 : 6
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
    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.defence]
    let classes: CardClasses = .neutral
    
    
    
    func amount(card: Card) -> Int {
        return (card.level > 0 ? 8 : 5)
    }
    
    func costFor(card: Card) -> Int { return 1 }
    
    func textFor(card: Card) -> String {
        return "Block for \(amount(card:card))"
    }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.willGainBlock(UpdateAmountEvent.init(targetActorUuid: source.uuid, sourceUuid: card.uuid, amount: self.amount(card: card)))
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
    
    let rarity: CardRarity = CardRarity.common
    let attributes: CardAttributes = [.potion, .heal]
    let classes: CardClasses = .neutral
    
    func costFor(card: Card) -> Int { return 0 }
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.expendCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.willGainHp(UpdateAmountEvent.init(targetActorUuid: source.uuid, sourceUuid: card.uuid, amount: 10)),
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}

class CardMasteryPotion: CardStrategy {
    
    let cardNumber: Int = 9
    let name =  "Mastery Potion"
    let cardText: String = "Upgrade each card in your hand. Expend Mastery Potion."
    var requiresSingleTarget: Bool = false
    
    
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = [.potion, .buff]
    let classes: CardClasses = .neutral
    
    func costFor(card: Card) -> Int { return 0 }
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        let player = battleState.actorWith(uuid: source.uuid)
        
        // For each card in the hand, add an upgrade event
        var events = player?.cardZones.hand.cards.map({ (card) in
            Event.upgradeCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid))
        }) ?? []
        
        // Add the expend event before this happens
        events.insert(Event.expendCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)), at: 0)
        
        battleState.eventHandler.push(events: events)
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
    
}
