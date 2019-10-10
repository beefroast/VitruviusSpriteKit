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
            Event.addEffect(
                DrainEffect.init(
                    ownerUuid: source.uuid,
                    sourceUuid: self.uuid
                ).withWrapper(uuid: UUID())
            ),
                
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
    
    class DrainEffect: HandleEffectStrategy {
        
        let ownerUuid: UUID
        let sourceUuid: UUID
        
        init(ownerUuid: UUID, sourceUuid: UUID) {
            self.ownerUuid = ownerUuid
            self.sourceUuid = sourceUuid
            super.init(identifier: .drain, effectName: "Drain")
        }
        
        override func handle(event: Event, state: BattleState, effectUuid: UUID) -> Bool {
            
            switch event {
            
            case .didLoseHp(let bodyEvent):
                
                guard bodyEvent.sourceUuid == self.sourceUuid else {
                    return false
                }
                
                state.eventHandler.push(
                    event: Event.willGainHp(
                        UpdateBodyEvent.init(
                            targetActorUuid: self.ownerUuid,
                            sourceUuid: effectUuid,
                            amount: bodyEvent.amount
                        )
                    )
                )
                
                return true
                
            case .onTurnEnded(_):
                return true
                
            default:
                return false
            }
        }
        
        // MARK: - Codable Implementation
        
        private enum CodingKeys: String, CodingKey {
            case ownerUuid
            case sourceUuid
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.ownerUuid = try values.decode(UUID.self, forKey: .ownerUuid)
            self.sourceUuid = try values.decode(UUID.self, forKey: .sourceUuid)
            try super.init(from: decoder)
        }

        override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.ownerUuid, forKey: .ownerUuid)
            try container.encode(self.sourceUuid, forKey: .sourceUuid)
        }
        
    }
}

