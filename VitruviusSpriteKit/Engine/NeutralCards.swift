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
    let uuid: UUID = UUID()
    let name =  "Strike"
    var cardText: String { get { return "Attack for 6." }}
    let requiresSingleTarget: Bool = true
    var cost: Int = 1
    var level: Int = 0
 
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        guard let target = target else {
            return
        }
        
        
        battleState.eventHandler.push(events: [
        
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid)),
            Event.attack(
                 AttackEvent(
                     sourceUuid: self.uuid,
                     sourceOwner: source.uuid,
                     targets: [target.uuid],
                     amount: 6
                 )
             )
             
        ])
        
        
 
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}



class CardDefend: CardStrategy {
    
    let cardNumber: Int = 5
    
    let uuid: UUID = UUID()
    let name =  "Defend"
    var cardText: String { get { return "Block for 5." }}
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        battleState.eventHandler.push(events: [
            Event.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: self.uuid)),
            Event.willGainBlock(UpdateBodyEvent.init(targetActorUuid: source.uuid, sourceUuid: self.uuid, amount: 5))
        ])
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}
