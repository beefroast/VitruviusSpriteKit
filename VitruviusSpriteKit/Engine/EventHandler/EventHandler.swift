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
    func handle(effect: Effect, event: Event, gameState: GameState) -> EffectResult
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
    
    func handle(event: Event, gameState: GameState) -> EffectResult {
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


protocol EventHandlerDelegate: AnyObject {
    func onEvent(sender: EventHandler, battleState: BattleState, event: Event)
    func onEventEnqueued(sender: EventHandler, event: Event)
    func onEventPushed(sender: EventHandler, event: Event)
    func onEventPopped(sender: EventHandler, event: Event)
}


class EventHandler: Codable {
    
    weak var delegate: EventHandlerDelegate? = nil
    
    let uuid: UUID
    var eventStack: StackQueue<Event>
    private var effectList: [Effect]
    
    init(uuid: UUID, eventStack: StackQueue<Event>, effectList: [Effect]) {
        self.uuid = uuid
        self.eventStack = eventStack
        self.effectList = effectList
    }
    
    func push(events: [Event]) -> Void {
        for e in events.reversed() {
            eventStack.push(elt: e)
            self.delegate?.onEventPushed(sender: self, event: e)
        }
    }
    
    func enqueue(events: [Event]) -> Void {
        for e in events {
            eventStack.enqueue(elt: e)
            self.delegate?.onEventEnqueued(sender: self, event: e)
        }
    }
    
    func push(event: Event) -> Void {
        eventStack.push(elt: event)
        self.delegate?.onEventPushed(sender: self, event: event)
    }
    
    func enqueue(event: Event) -> Void {
        eventStack.enqueue(elt: event)
        self.delegate?.onEventEnqueued(sender: self, event: event)
    }
    
    func appendToEffectsList(effect: Effect) {
        self.effectList.append(effect)
    }
    
    
    func flushEvents(battleState: BattleState) -> Void {
        
        var playerInputRequired = self.popAndHandle(battleState: battleState)
        
        while playerInputRequired == false {
            playerInputRequired = self.popAndHandle(battleState: battleState)
        }
    }
    
    func popAndHandle(battleState: BattleState) -> Bool {
        guard let e = eventStack.pop() else { return false }
        self.delegate?.onEventPopped(sender: self, event: e)
        let playerInputRequired = self.handle(event: e, battleState: battleState)
        return playerInputRequired
    }
    
    func handle(event: Event, battleState: BattleState) -> Bool {
        
        // Loop through the effect list
//        self.effectList.removeAll { (effect) -> Bool in
//            effect.handle(event: event, state: battleState)
//        }
        
        // Post the event to the delegate, this is used to
        // allow the game to perform animation and respond to
        // events, we don't want the game manager in the effects
        // list because then it's more difficult to serialize
        self.delegate?.onEvent(sender: self, battleState: battleState, event: event)
    
        switch event {
            
        case .playerInputRequired:
            return true
            
        case .onBattleBegan:
            
            // The player draws their hand
            self.enqueue(event: Event.willDrawCards(DrawCardsEvent.init(actorUuid: battleState.player.uuid, amount: 5)))
            
            // The enemies draw their hand
            // TODO: This number of cards drawn shouldn't be specified here
            battleState.enemies.forEach { (enemy) in
                self.enqueue(event: Event.willDrawCards(DrawCardsEvent.init(actorUuid: enemy.uuid, amount: 2)))
            }
            
            // The enemy plans their turns
            let enemyPlansEvents = battleState.enemies.map({ $0.planTurn(state: battleState) })
            self.enqueue(events: enemyPlansEvents)
            
            // Enqueue the turn order
            let enemyTurnsStart = battleState.enemies.map({ Event.onTurnBegan(ActorEvent.init(actorUuid: $0.uuid)) })
            self.enqueue(events: [Event.onTurnBegan(ActorEvent.init(actorUuid: battleState.player.uuid))] + enemyTurnsStart)
            
        
        
        case .onTurnBegan(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            if actor.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            
            self.push(event:
                Event.willLoseBlock(UpdateAmountEvent.init(
                    targetActorUuid: e.actorUuid,
                    sourceUuid: uuid,
                    amount: actor.body.block)))
        
        case .onTurnEnded(let e):
            self.enqueue(event: Event.onTurnBegan(ActorEvent.init(actorUuid: e.actorUuid)))
            
        case .addEffect(let effect):
            self.effectList.insert(effect, at: 0)
            
        case .removeEffect(let effect):
            self.effectList.removeAll { (e) -> Bool in
                e.uuid == effect.uuid
            }
        
        case .drawCard(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            guard actor.cardZones.drawPile.hasDraw() else {
                guard actor.cardZones.discard.isEmpty == false else {
                    // Cannot draw a card or reshuffle so do nothing instead
                    return false
                }
                
                // Reshuffle and then draw again
                self.push(events: [
                    Event.shuffleDiscardIntoDrawPile(ActorEvent.init(actorUuid: e.actorUuid)),
                    Event.drawCard(ActorEvent.init(actorUuid: e.actorUuid))
                ])
                return false
            }
            
            // Draw a card
            guard let card = actor.cardZones.drawPile.drawRandom(rng: battleState.rng.drawRng) else {
                return false
            }
            
            // Put the card in their hand
            actor.cardZones.hand.cards.append(card)
            self.push(event: Event.onCardDrawn(CardEvent.init(actorUuid: actor.uuid, cardUuid: card.uuid)))
            
        case .discardCard(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }

            actor.cardZones.discard(cardUuid: e.cardUuid)
        
        case .destroyCard(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            actor.cardZones.remove(cardUuid: e.cardUuid)
            
        case .expendCard(let e):
            
            // TODO: Remove the card from the deck
            // This needs to refer back to the game state, more
            // persistant than the battle state.
            // For now we just destroy the card
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            actor.cardZones.remove(cardUuid: e.cardUuid)
            
        case .upgradeCard(let e):
            
            // TODO: This only upgrades a card in someone's hand, we should make this more general
            guard let card = battleState.actorWith(uuid: e.actorUuid)?.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                return false
            }
            
            // TODO: In the future we might want more than one upgrade
            card.level = 1
            
        case .discardHand(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            self.push(events:
                actor.cardZones.hand.cards.map({
                    Event.discardCard(CardEvent.init(actorUuid: actor.uuid, cardUuid: $0.uuid))
                })
            )
            
        case .willDrawCards(let e):
            
            // Enqueue a draw for each in amount
            guard e.amount > 0 else { return false }
            for _ in 0...e.amount-1 {
                self.push(event: Event.drawCard(ActorEvent(actorUuid: e.actorUuid)))
            }
            
        case .onCardDrawn(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            guard let card = actor.cardZones.hand.cards.first(where: { (c) -> Bool in
                c.uuid == e.cardUuid
            }) else {
                return false
            }
            
            
            
//            card.onDrawn(source: actor, battleState: battleState)
            
        case .shuffleDiscardIntoDrawPile(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }

            let discardedCards = actor.cardZones.discard.asArray()
            actor.cardZones.discard.removeAll()
            actor.cardZones.drawPile.shuffleIn(cards: discardedCards)
            
        case .willLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return false
            }
            
            // Calculate the amount of lost HP
            let remainingHp = max(actor.body.hp - e.amount, 0)
            let lostHp = actor.body.hp - remainingHp
            guard lostHp > 0 else {
                return false
            }
            actor.body.hp -= lostHp
            self.push(event: Event.didLoseHp(e.with(amount: lostHp)))
            
        case .willLoseBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return false
            }
            
            // Calculate the amount of lost block
            let remainingBlock = max(actor.body.block - e.amount, 0)
            let lostBlock = actor.body.block - remainingBlock
            guard lostBlock > 0 else {
                return false
            }
            actor.body.block -= lostBlock
            self.push(event: Event.didLoseBlock(e.with(amount: lostBlock)))
            
        case .didLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return false
            }
            
            // TODO: This is a little dodgey
            if actor.body.hp == 0 {
                if actor.faction == .enemies {
                    self.push(event: Event.onEnemyDefeated(ActorEvent.init(actorUuid: actor.uuid)))
                } else if actor.faction == .player {
                    self.push(event: Event.onBattleLost)
                }
            }
            
        case .didLoseBlock(let e):
            break
            
        case .willGainHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return false
            }
            
            // Gain up to your maximum HP
            let nextHp = min(actor.body.hp + e.amount, actor.body.maxHp)
            let gainedLife = nextHp - actor.body.hp
            actor.body.hp += gainedLife
            let event = e.with(amount: gainedLife)
            self.push(event: Event.didGainHp(event))
            
        case .willGainBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return false
            }
            
            actor.body.block += e.amount
            self.push(event: Event.didGainBlock(e))
            
        case .didGainHp(let e):
            break
            
        case .didGainBlock(let e):
            break
            
        case .willGainMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return false
            }
            actor.currentMana += e.amount
            
        case .willLoseMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return false
            }
            actor.currentMana = max(actor.currentMana - e.amount, 0)
            
        case .playCard(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                break
            }
            
            if actor.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            
            guard let card = actor.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                break
            }
            
            // Pay the mana cost...
            self.push(
                event: Event.willLoseMana(
                    UpdateAmountEvent.init(
                        targetActorUuid: e.actorUuid,
                        sourceUuid: card.uuid,
                        amount: card.cost
                    )
                )
            )

            
            // Resolve the card...
            
//            card.resolve(
//                source: actor,
//                battleState: battleState,
//                target: e.target.flatMap(battleState.actorWith(uuid:))
//            )
            
        case .attack(let e):
            
            e.targets.forEach { (targetUuid) in
                
                // Send the event to reduce the block
                guard let target = battleState.actorWith(uuid: targetUuid) else {
                    return
                }
                
                let updatedBlock = max(target.body.block - e.amount, 0)
                let blockLost = target.body.block - updatedBlock
                let damageRemaining = e.amount - blockLost
                
                if damageRemaining > 0 {
                    self.push(event: Event.willLoseHp(UpdateAmountEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: damageRemaining)))
                }
                
                self.push(event: Event.willLoseBlock(
                    UpdateAmountEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: blockLost)
                ))
            }
            
        case .onEnemyDefeated(let e):
            
            battleState.enemies.removeAll { (enemy) -> Bool in
                enemy.uuid == e.actorUuid
            }
            
            // Remove the queued start of turn from the queue...
            self.eventStack.removeWhere { (event) -> Bool in
                switch event {
                case .onTurnBegan(let turnBeganEvent): return turnBeganEvent.actorUuid == e.actorUuid
                default: return false
                }
            }
            
            // If there's no enemies, post a win event
            if battleState.enemies.count == 0 {
                self.push(event: Event.onBattleWon)
            }
        
        case .onBattleWon:
            break
            
        case .onBattleLost:
            // Push a player input required here
            self.push(event: Event.playerInputRequired)
            
        }
        
        return false
        
    }
    
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case eventStack
        case effectList
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try values.decode(UUID.self, forKey: .uuid)
        self.eventStack = try values.decode(StackQueue<Event>.self, forKey: .eventStack)
        self.effectList = try values.decode([Effect].self, forKey: .effectList)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.uuid, forKey: .uuid)
        try container.encode(self.eventStack, forKey: .eventStack)
        try container.encode(self.effectList, forKey: .effectList)
    }
    
}






