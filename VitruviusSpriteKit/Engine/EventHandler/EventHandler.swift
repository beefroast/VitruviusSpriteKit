//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


struct EffectResult {
    
    let consumeEvent: Bool
    let consumeEffect: Bool
    
    static var consumeEffect = EffectResult.init(consumeEvent: false, consumeEffect: true)
    static var noChange = EffectResult.init(consumeEvent: false, consumeEffect: false)
}

protocol EffectStrategy: Codable {
    func handle(effect: Effect, event: EventType, gameState: GameState) -> EffectResult
}

extension EffectStrategy {
    func withEffect(uuid: UUID, owner: UUID) -> Effect {
        return Effect(uuid: uuid, owner: owner, strategy: self)
    }
}

class Effect: Codable {
    
    let uuid: UUID
    let owner: UUID
    let strategy: EffectStrategy
    
    init(uuid: UUID, owner: UUID, strategy: EffectStrategy) {
        self.uuid = uuid
        self.owner = owner
        self.strategy = strategy
    }
    
    func handle(event: EventType, gameState: GameState) -> EffectResult {
        self.strategy.handle(effect: self, event: event, gameState: gameState)
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case owner
        case uuid
        case strategyName
        case strategyData
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.owner = try values.decode(UUID.self, forKey: .owner)
        fatalError()
    }
}

class EChannel: EffectStrategy {
    
    let actorUuid: UUID
    let eventUuid: UUID
    
    init(actorUuid: UUID, eventUuid: UUID) {
        self.actorUuid = actorUuid
        self.eventUuid = eventUuid
    }
    
    func handle(effect: Effect, event: EventType, gameState: GameState) -> EffectResult {
        switch event {
        
        case .concentrationBroken(let e):
            guard e.actorUuid == actorUuid else { return EffectResult.noChange }
            gameState.currentBattle!.eventHandler.push(events: [
                EventType.cancelChanelledEvent(eventUuid),
                EventType.turnBegan(actorUuid)
            ])
            return EffectResult.consumeEffect
            
        default: return EffectResult.noChange
        
        }
    }
}


