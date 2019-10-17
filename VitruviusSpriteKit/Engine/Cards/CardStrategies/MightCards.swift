//
//  MightCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class CSDiamondBody: CardStrategy {
    
    let cardNumber: Int = 10
    let name: String = "Diamond Body"
    let requiresSingleTarget: Bool = false
    let rarity: CardRarity = .rare
    let attributes: CardAttributes = .buff
    let classes: CardClasses = .might
    
    func amountPrevented(card: Card) -> Int {
        return card.level > 0 ? 2 : 1
    }
    
    func textFor(card: Card) -> String {
        return "Whenever you would lose HP, lose \(amountPrevented(card: card)) fewer."
    }
    
    func costFor(card: Card) -> Int {
        return 2
    }
    
    func resolve(card: Card, source: Actor, battleState: BattleState, target: Actor?) {
        
    }
    
    func onDrawn(card: Card, source: Actor, battleState: BattleState) {}
    func onDiscarded(card: Card, source: Actor, battleState: BattleState) {}
    
    class EDiamondBody: Effect {
    }
}



