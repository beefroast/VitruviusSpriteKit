//
//  FaithCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardDrain: ICard {

    let cardNumber: Int = 4
    
    var uuid: UUID = UUID()
    var name: String = "Drain"
    var cardText: String { get { return "Attack for 6. Gain life equal to the hp lost this way." }}
    var requiresSingleTarget: Bool = true
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {

        guard let target = target?.uuid else {
            return
        }
        
        battleState.eventHandler.push(events: [
            
            // Listen for damage done by this source, and gain that much life
            Event.addEffect(DrainEffect(
                owner: source,
                sourceUuid:
                source.uuid
            )),
            
            // Attack for 6
            Event.attack(AttackEvent.init(
                sourceUuid: self.uuid,
                sourceOwner: source.uuid,
                targets: [target],
                amount: 6
            )),
            
            // Discard this card
            Event.discardCard(CardEvent.init(
                actorUuid: source.uuid,
                cardUuid: self.uuid
            )),
            
        ])
        
    }
    

    
    func onDrawn(source: Actor, battleState: BattleState) {
    }
    
    func onDiscarded(source: Actor, battleState: BattleState) {
    }
    
    class DrainEffect: IEffect {
        
        let owner: Actor
        let sourceUuid: UUID
        var uuid: UUID = UUID()
        var name: String = "Drain"
        
        init(owner: Actor, sourceUuid: UUID) {
            self.owner = owner
            self.sourceUuid = sourceUuid
        }
        
        func handle(event: Event, state: BattleState) -> Bool {
            
            switch event {
            
            case .didLoseHp(let bodyEvent):
                
                guard bodyEvent.sourceUuid == self.sourceUuid else {
                    return false
                }
                
                state.eventHandler.push(event: Event.willGainHp(UpdateBodyEvent.init(targetActorUuid: self.owner.uuid, sourceUuid: self.uuid, amount: bodyEvent.amount)))
                
                return true
                
            case .onTurnEnded(_):
                return true
                
            default:
                return false
            }
        }
    }
}

