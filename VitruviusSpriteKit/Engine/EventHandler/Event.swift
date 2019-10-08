//
//  Event.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 8/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

enum Event {
    
    case playerInputRequired
    
    case onBattleBegan
    
    case onEnemyPlannedTurn(EnemyTurnEffect)
    
    case onTurnBegan(ActorEvent)
    case onTurnEnded(ActorEvent)
    
    case addEffect(IEffect)
    case removeEffect(IEffect)
    
    case willDrawCards(DrawCardsEvent)
    case drawCard(ActorEvent)
    case onCardDrawn(CardEvent)
    case discardCard(CardEvent)
    case discardHand(ActorEvent)
    case destroyCard(CardEvent)
    case shuffleDiscardIntoDrawPile(ActorEvent)
        
    case willLoseHp(UpdateBodyEvent)
    case willLoseBlock(UpdateBodyEvent)
    case didLoseHp(UpdateBodyEvent)
    case didLoseBlock(UpdateBodyEvent)
    
    case willGainHp(UpdateBodyEvent)
    case willGainBlock(UpdateBodyEvent)
    case didGainHp(UpdateBodyEvent)
    case didGainBlock(UpdateBodyEvent)
    
    case playCard(CardEvent, UUID?)
    case attack(AttackEvent)
    
    case onEnemyDefeated(ActorEvent)
    
    case onBattleWon
    case onBattleLost
}

class CardEvent {
    let actorUuid: UUID
    let cardUuid: UUID
    init(actorUuid: UUID, cardUuid: UUID) {
        self.actorUuid = actorUuid
        self.cardUuid = cardUuid
    }
}

class PlayCardEvent: CardEvent {
    let targets: [UUID]
    init(actorUuid: UUID, cardUuid: UUID, targets: [UUID]) {
        self.targets = targets
        super.init(actorUuid: actorUuid, cardUuid: cardUuid)
    }
}


class ActorEvent {
    var actorUuid: UUID
    init(actorUuid: UUID) {
        self.actorUuid = actorUuid
    }
}

class DrawCardsEvent {
    var actorUuid: UUID
    var amount: Int
    init(actorUuid: UUID, amount: Int) {
        self.actorUuid = actorUuid
        self.amount = amount
    }
}


class AttackEvent {
    
    let sourceUuid: UUID
    var sourceOwner: UUID
    var targets: [UUID]
    var amount: Int
    
    init(sourceUuid: UUID, sourceOwner: UUID, targets: [UUID], amount: Int) {
        self.sourceUuid = sourceUuid
        self.sourceOwner = sourceOwner
        self.targets = targets
        self.amount = amount
    }
}

class UpdateBodyEvent {
    
    var targetActorUuid: UUID
    let sourceUuid: UUID
    var amount: Int
    
    init(targetActorUuid: UUID, sourceUuid: UUID, amount: Int) {
        self.targetActorUuid = targetActorUuid
        self.sourceUuid = sourceUuid
        self.amount = amount
    }
    
    func with(amount: Int) -> UpdateBodyEvent {
        return UpdateBodyEvent(
            targetActorUuid: self.targetActorUuid,
            sourceUuid: self.sourceUuid,
            amount: amount
        )
    }
}
