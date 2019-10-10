//
//  GuileCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardMistForm: ICard {
    
    let cardNumber: Int = 2
    
    var uuid: UUID = UUID()
    var name: String = "Mist Form"
    var cardText: String { get { return "Until you next turn, attacks against you are reduced to 0." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid)),
            Event.addEffect(
                MistFormEffect.init(ownerUuid: source.uuid).withWrapper(uuid: UUID())
            )
        ])
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
    class MistFormEffect: IEffect, Codable {
        
        let identifier: EffectIdentifier = .mistForm
        let effectName: String = "Mist Form"
        let ownerUuid: UUID
        
        init(ownerUuid: UUID) {
            self.ownerUuid = ownerUuid
        }
        
        func handle(event: Event, state: BattleState, effectUuid: UUID) -> Bool {
            switch event {
                
            case .attack(let attackEvent):
                attackEvent.amount = 0
                return true
                
            default:
                return false
            }
        }
        
    }
}

class CardPierce: ICard {
    
    let cardNumber: Int = 3
    
    var uuid: UUID = UUID()
    var name: String = "Pierce"
    var cardText: String { get { return "Target loses 18 hp." }}
    var requiresSingleTarget: Bool = true
    var cost: Int = 2
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        let discardEvent = Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid))
        
        guard let drainTarget = target else {
            battleState.eventHandler.push(events: [discardEvent])
            return
        }
        
        return battleState.eventHandler.push(events: [
            discardEvent,
            Event.willLoseHp(UpdateBodyEvent.init(targetActorUuid: drainTarget.uuid, sourceUuid: self.uuid, amount: 18))
        ])
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}
