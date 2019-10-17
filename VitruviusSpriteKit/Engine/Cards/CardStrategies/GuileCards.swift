//
//  GuileCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardMistForm: CardStrategy {
    
    let cardNumber: Int = 2
    
    var name: String = "Mist Form"
    var cardText: String { get { return "Until you next turn, attacks against you are reduced to 0." }}
    var requiresSingleTarget: Bool = false
    
    
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = .buff
    let classes: CardClasses = .guile
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func costFor(card: Card) -> Int { return 2 }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            Event.addEffect(
                MistFormEffect.init(ownerUuid: source.uuid).withWrapper(uuid: UUID())
            )
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
    
    class MistFormEffect: HandleEffectStrategy {
        
        let ownerUuid: UUID
        
        init(ownerUuid: UUID) {
            self.ownerUuid = ownerUuid
            super.init(
                identifier: .mistForm,
                effectName: "Mistform"
            )
        }
        
        override func handle(event: Event, state: BattleState, effectUuid: UUID) -> Bool {
            switch event {
                
            case .attack(let attackEvent):
                attackEvent.amount = 0
                return true
                
            default:
                return false
            }
        }
        
        // MARK: - Codable Implementation
        
        private enum CodingKeys: String, CodingKey {
            case ownerUuid
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.ownerUuid = try values.decode(UUID.self, forKey: .ownerUuid)
            try super.init(from: decoder)
        }

        override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.ownerUuid, forKey: .ownerUuid)
        }
    }
}

class CardPierce: CardStrategy {
    
    let cardNumber: Int = 3
    
    var name: String = "Pierce"
    var cardText: String { get { return "Target loses 18 hp." }}
    var requiresSingleTarget: Bool = true
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = [.attack, .ranged]
    let classes: CardClasses = .guile
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func costFor(card: Card) -> Int { return 2 }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
        let discardEvent = Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid))
        
        guard let drainTarget = target else {
            battleState.eventHandler.push(events: [discardEvent])
            return
        }
        
        return battleState.eventHandler.push(events: [
            discardEvent,
            Event.willLoseHp(UpdateAmountEvent.init(targetActorUuid: drainTarget.uuid, sourceUuid: card.uuid, amount: 18))
        ])
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
}
