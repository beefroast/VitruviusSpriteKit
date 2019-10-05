//
//  MightCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

// Invent something that only lasts until the end of the turn

//class CardAngryPants: ICard {
//
//    var uuid: UUID = UUID()
//    var name: String = "Angry Pants"
//    var requiresSingleTarget: Bool = false
//    var cost: Int = 1
//
//    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
//        <#code#>
//    }
//
//    func onDrawn(source: Actor, battleState: BattleState) {}
//
//    func onDiscarded(source: Actor, battleState: BattleState) {}
//
//    class EffectAngryPants: IEffect {
//
//        var uuid: UUID
//        var name: String
//        func handle(event: Event, state: BattleState) -> Bool {
//            <#code#>
//        }
//
//
//    }
//
//
//}


//class CardDiamondBody: Card {
//    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
//        state.playerState.body = DiamondBody.init(body: state.playerState.body)
//        return Promise<Void>()
//    }
//    static func newInstance() -> Card {
//        return CardDiamondBody(
//            uuid: UUID(),
//            name: "Diamond Body",
//            cost: Cost.free(),
//            text: "Whenever you would lose HP, lose 1 fewer HP."
//        )
//    }
//}
//
//
//class DiamondBody: BodyProxy {
//    override func loseHp(damage: Int) -> (Int, IBody) {
//        return super.loseHp(damage: damage-1)
//    }
//}
