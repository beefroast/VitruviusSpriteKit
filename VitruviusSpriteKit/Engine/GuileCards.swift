//
//  GuileCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardMistForm: ICard {
    
    var uuid: UUID = UUID()
    var name: String = "Mist Form"
    var cardText: String { get { return "Until you next turn, attacks against you are reduced to 0." }}
    var requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(events: [
            Event.addEffect(MistFormEffect(owner: source)),
            Event.discardCard(DiscardCardEvent.init(actor: source, card: self))
        ])
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
    class MistFormEffect: IEffect {
        
        let owner: Actor
        var uuid: UUID = UUID()
        var name: String = "Mist Form"
        
        init(owner: Actor) {
            self.owner = owner
        }
        
        func handle(event: Event, state: BattleState) -> Bool {
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
    
    var uuid: UUID = UUID()
    var name: String = "Pierce"
    var cardText: String { get { return "Target loses 18 hp." }}
    var requiresSingleTarget: Bool = true
    var cost: Int = 2
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        // Push the discard effect
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        // Attack straight through ignore armour
        battleState.eventHandler.push(
            event: Event.willLoseHp(
                UpdateBodyEvent.init(
                    player:
                    source,
                    sourceUuid: self.uuid,
                    amount: 18
                )
            )
        )
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}
