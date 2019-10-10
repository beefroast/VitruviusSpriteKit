//
//  Event.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 8/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

enum Event: Codable {

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
    
    case playCard(PlayCardEvent)
    case attack(AttackEvent)
    
    case onEnemyDefeated(ActorEvent)
    
    case onBattleWon
    case onBattleLost
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        
        self = .playerInputRequired
        
        switch type {
        
        case "playerInputRequired":
            self = .playerInputRequired
            
        case "onBattleBegan":
            self = .onBattleBegan
            
        case "onEnemyPlannedTurn":
            let data = try values.decode(EnemyTurnEffect.self, forKey: .data)
            self = .onEnemyPlannedTurn(data)
            
        case "onTurnBegan":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .onTurnBegan(data)
            
        case "onTurnEnded":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .onTurnEnded(data)
            
        case "addEffect":
            break
//            let data = try values.decode(CardEvent.self, forKey: .data)
//            self = .addEffect(data)
            
        case "removeEffect":
            break
//            let data = try values.decode(CardEvent.self, forKey: .data)
//            self = .removeEffect(data)
            
        case "willDrawCards":
            let data = try values.decode(DrawCardsEvent.self, forKey: .data)
            self = .willDrawCards(data)
            
        case "drawCard":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .drawCard(data)
            
        case "onCardDrawn":
            let data = try values.decode(CardEvent.self, forKey: .data)
            self = .onCardDrawn(data)
            
        case "discardCard":
            let data = try values.decode(CardEvent.self, forKey: .data)
            self = .discardCard(data)
            
        case "discardHand":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .discardHand(data)
            
        case "destroyCard":
            let data = try values.decode(CardEvent.self, forKey: .data)
            self = .destroyCard(data)
            
        case "shuffleDiscardIntoDrawPile":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .shuffleDiscardIntoDrawPile(data)
            
        case "willLoseHp":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .willLoseHp(data)
            
        case "willLoseBlock":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .willLoseBlock(data)
            
        case "didLoseHp":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .didLoseHp(data)
            
        case "didLoseBlock":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .didLoseBlock(data)
            
        case "willGainHp":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .willGainHp(data)
            
        case "willGainBlock":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .willGainBlock(data)
            
        case "didGainHp":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .didGainHp(data)
            
        case "didGainBlock":
            let data = try values.decode(UpdateBodyEvent.self, forKey: .data)
            self = .didGainBlock(data)
            
        case "playCard":
            let data = try values.decode(PlayCardEvent.self, forKey: .data)
            self = .playCard(data)
            
        case "attack":
            let data = try values.decode(AttackEvent.self, forKey: .data)
            self = .attack(data)
            
        case "onEnemyDefeated":
            let data = try values.decode(ActorEvent.self, forKey: .data)
            self = .onEnemyDefeated(data)
            
        case "onBattleWon":
            self = .onBattleWon
            
        case "onBattleLost":
            self = .onBattleLost
            
        default: break
            
        }

    }

    func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        
        case .playerInputRequired:
            try container.encode("playerInputRequired", forKey: .type)
            
        case .onBattleBegan:
            try container.encode("onBattleBegan", forKey: .type)
            
        case .onEnemyPlannedTurn(let e):
            try container.encode("onEnemyPlannedTurn", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .onTurnBegan(let e):
            try container.encode("onTurnBegan", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .onTurnEnded(let e):
            try container.encode("onTurnEnded", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .addEffect(let e): break
//            try container.encode("addEffect", forKey:. type)
//            try container.encode(e, forKey: .data)
            
        case .removeEffect(let e): break
//            try container.encode("removeEffect", forKey:. type)
//            try container.encode(e, forKey: .data)
            
        case .willDrawCards(let e):
            try container.encode("willDrawCards", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .drawCard(let e):
            try container.encode("drawCard", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .onCardDrawn(let e):
            try container.encode("onCardDrawn", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .discardCard(let e):
            try container.encode("discardCard", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .discardHand(let e):
            try container.encode("discardHand", forKey:. type)
            try container.encode(e, forKey: .data)
            
        case .destroyCard(let e):
            try container.encode("destroyCard", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .shuffleDiscardIntoDrawPile(let e):
            try container.encode("shuffleDiscardIntoDrawPile", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .willLoseHp(let e):
            try container.encode("willLoseHp", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .willLoseBlock(let e):
            try container.encode("willLoseBlock", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .didLoseHp(let e):
            try container.encode("didLoseHp", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .didLoseBlock(let e):
            try container.encode("didLoseBlock", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .willGainHp(let e):
            try container.encode("willGainHp", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .willGainBlock(let e):
            try container.encode("willGainBlock", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .didGainHp(let e):
            try container.encode("didGainHp", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .didGainBlock(let e):
            try container.encode("didGainBlock", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .playCard(let e):
            try container.encode("playCard", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .attack(let e):
            try container.encode("attack", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .onEnemyDefeated(let e):
            try container.encode("onEnemyDefeated", forKey: .type)
            try container.encode(e, forKey: .data)
            
        case .onBattleWon:
            try container.encode("onBattleWon", forKey: .type)
            
        case .onBattleLost:
            try container.encode("onBattleLost", forKey: .type)
        }
     }
     

    

    
}

class CardEvent: Codable {
    let actorUuid: UUID
    let cardUuid: UUID
    init(actorUuid: UUID, cardUuid: UUID) {
        self.actorUuid = actorUuid
        self.cardUuid = cardUuid
    }
}

class PlayCardEvent: Codable {
    let actorUuid: UUID
    let cardUuid: UUID
    let target: UUID?
    init(actorUuid: UUID, cardUuid: UUID, target: UUID? = nil) {
        self.actorUuid = actorUuid
        self.cardUuid = cardUuid
        self.target = target
    }
}


class ActorEvent: Codable {
    var actorUuid: UUID
    init(actorUuid: UUID) {
        self.actorUuid = actorUuid
    }
}

class DrawCardsEvent: Codable {
    var actorUuid: UUID
    var amount: Int
    init(actorUuid: UUID, amount: Int) {
        self.actorUuid = actorUuid
        self.amount = amount
    }
}


class AttackEvent: Codable {
    
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

class UpdateBodyEvent: Codable {
    
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
