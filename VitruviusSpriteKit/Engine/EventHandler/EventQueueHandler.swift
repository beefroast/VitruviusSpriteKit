//
//  EventQueue.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class EventQueueHandler: Codable {
    
    private var eventQueue: PriorityQueue<EventType>
    private var effectList: PriorityQueue<Effect>
    
    init(
        eventQueue: PriorityQueue<EventType> = PriorityQueue(),
        effectList: PriorityQueue<Effect> = PriorityQueue()) {
        self.eventQueue = eventQueue
        self.effectList = effectList
    }
    
    func push(event: EventType, priority: Int = 0, shouldQueue: Bool = false) {
        _ = self.eventQueue.insert(element: event, priority: priority, shouldQueue: shouldQueue)
    }
    
    func push(events: [EventType]) {
        for e in events.reversed() {
            _ = self.eventQueue.insert(element: e, priority: 0)
        }
    }
    
    func hasCurrentEvent() -> Bool {
        return self.eventQueue.head?.priority == 0
    }

    
    func popAndHandle(state: GameState) -> EventType? {
        
        guard let battleState = state.currentBattle else { return nil }
        guard let e = self.eventQueue.popNext() else { return nil }
        
        var isEventConsumed: Bool = false
        
        self.effectList.removeWhere { (effect) -> Bool in
            guard isEventConsumed == false else { return false }
            let result = effect.handle(event: e, gameState: state)
            isEventConsumed = result.consumeEvent
            return result.consumeEffect
        }
        
        // If the event was consumed, we no longer handle it here
        if isEventConsumed { return nil }
        
        switch e {
            
        case .tick:
            self.eventQueue.forEach { (e) in
                e.priority -= 1
            }
                
        case .playerInputRequired:
            break
            
        case .chanelledEvent(let e):
            e.onChannelled(battleState: battleState)
            
        case .cancelChanelledEvent(let uuid):
            self.eventQueue.removeWhere { (e) -> Bool in
                switch e {
                case .chanelledEvent(let e): return e.uuid == uuid
                default: return false
                }
            }
            
        case .onBattleBegan:
            
            // Enemies plan their turns
            
            battleState.enemies.forEach { (enemy: Enemy) in
                enemy.planTurn(state: battleState)
            }
            
            // It's the player's turn
            _ = self.push(event: EventType.turnBegan(battleState.player.uuid))
            
            // The player draws their hand
            _ = self.push(event: EventType.willDrawCards(DrawCardsEvent.init(actorUuid: battleState.player.uuid, amount: 5)))
            
        case .addEffect(let effect):
            _ = self.effectList.insert(element: effect, priority: 0)
            
        case .removeEffect(let effect):
            self.effectList.removeWhere { (effect) -> Bool in
                effect.uuid == effect.uuid
            }

        case .drawCard(let e):
            
            let actor = battleState.player
            
            guard actor.cardZones.drawPile.hasDraw() else {
                guard actor.cardZones.discard.isEmpty == false else {
                    // Cannot draw a card or reshuffle so do nothing instead
                    return nil
                }
                
                // Reshuffle and then draw again
                self.push(events: [
                    EventType.shuffleDiscardIntoDrawPile(ActorEvent.init(actorUuid: e.actorUuid)),
                    EventType.drawCard(ActorEvent.init(actorUuid: e.actorUuid))
                ])
                return nil
            }
            
            // Draw a card
            guard let card = actor.cardZones.drawPile.drawRandom(rng: battleState.rng.drawRng) else {
                return nil
            }
            
            // Put the card in their hand
            actor.cardZones.hand.cards.append(card)
            _ = self.push(event: EventType.onCardDrawn(CardEvent.init(actorUuid: actor.uuid, cardUuid: card.uuid)))
            
        case .discardCard(let e):
            battleState.player.cardZones.discard(cardUuid: e.cardUuid)

        case .destroyCard(let e):
            battleState.player.cardZones.remove(cardUuid: e.cardUuid)
            
        case .expendCard(let e):
            battleState.player.cardZones.remove(cardUuid: e.cardUuid)
            state.playerData.decklist.removeAll { (c) -> Bool in
                c.uuid == e.cardUuid
            }
            
        case .upgradeCard(let e):
            guard let card = battleState.actorWith(uuid: e.actorUuid)?.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                return nil
            }
            
            // TODO: In the future we might want more than one upgrade
            card.level += 1
            
        case .discardHand(let e):
            let player = battleState.player
            self.push(events:
                player.cardZones.hand.cards.map({
                    EventType.discardCard(CardEvent.init(actorUuid: player.uuid, cardUuid: $0.uuid))
                })
            )
            
        case .willDrawCards(let e):
            
            // Enqueue a draw for each in amount
            guard e.amount > 0 else { return nil }
            for _ in 0...e.amount-1 {
                _ = self.push(event: EventType.drawCard(ActorEvent(actorUuid: e.actorUuid)))
            }
            
        case .onCardDrawn(let e):
            let actor = battleState.player
            
            guard let card = actor.cardZones.hand.cards.first(where: { (c) -> Bool in
                c.uuid == e.cardUuid
            }) else {
                return nil
            }
            
        case .shuffleDiscardIntoDrawPile(let e):
            let actor = battleState.player

            let discardedCards = actor.cardZones.discard.asArray()
            actor.cardZones.discard.removeAll()
            actor.cardZones.drawPile.shuffleIn(cards: discardedCards)
            
        case .refreshHand:
            let actor = battleState.player
            
            // Costs 5 by default, maybe this can be upgraded
            self.push(event: EventType.playerInputRequired, priority: 5)
            
            self.push(events: [
                EventType.discardHand(ActorEvent.init(actorUuid: actor.uuid)),
                EventType.willDrawCards(DrawCardsEvent.init(actorUuid: actor.uuid, amount: 5))
            ])
            
        case .willLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return nil
            }
            
            // Calculate the amount of lost HP
            let remainingHp = max(actor.body.hp - e.amount, 0)
            let lostHp = actor.body.hp - remainingHp
            guard lostHp > 0 else {
                return nil
            }
            actor.body.hp -= lostHp
            self.push(event: EventType.didLoseHp(e.with(amount: lostHp)))
            
        case .willLoseBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return nil
            }
            
            // Calculate the amount of lost block
            let remainingBlock = max(actor.body.block - e.amount, 0)
            let lostBlock = actor.body.block - remainingBlock
            guard lostBlock > 0 else {
                return nil
            }
            actor.body.block -= lostBlock
            self.push(event: EventType.didLoseBlock(e.with(amount: lostBlock)))
            
        case .didLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return nil
            }
            
            
            
            // TODO: This is a little dodgey
            if actor.body.hp == 0 {
                if actor.faction == .enemies {
                    self.push(event: EventType.onEnemyDefeated(ActorEvent.init(actorUuid: actor.uuid)))
                } else if actor.faction == .player {
                    self.push(event: EventType.onBattleLost)
                }
            }
            
            self.eventQueue.insert(element: EventType.concentrationBroken(ActorEvent.init(actorUuid: actor.uuid)))
            
        case .didLoseBlock(let e):
            break
            
        case .willGainHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return nil
            }
            
            // Gain up to your maximum HP
            let nextHp = min(actor.body.hp + e.amount, actor.body.maxHp)
            let gainedLife = nextHp - actor.body.hp
            actor.body.hp += gainedLife
            let event = e.with(amount: gainedLife)
            self.push(event: EventType.didGainHp(event))
            
        case .willGainBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return nil
            }
            
            actor.body.block += e.amount
            self.push(event: EventType.didGainBlock(e))
            
        case .didGainHp(let e):
            break
            
        case .didGainBlock(let e):
            break
            
        case .willGainMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return nil
            }
            actor.currentMana += e.amount
            
        case .willLoseMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return nil
            }
            actor.currentMana = max(actor.currentMana - e.amount, 0)
            
        case .playCard(let e):
            
            let player = battleState.player

            guard let card = player.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                return nil
            }
            
            
            // Play the card
            card.resolve(source: player, gameState: state, target: e.target.flatMap(battleState.actorWith(uuid:)))
            
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
                    self.push(event: EventType.willLoseHp(UpdateAmountEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: damageRemaining)))
                }
                
                self.push(event: EventType.willLoseBlock(
                    UpdateAmountEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: blockLost)
                ))
            }
            
        case .onEnemyDefeated(let e):
            
            battleState.enemies.removeAll { (enemy) -> Bool in
                enemy.uuid == e.actorUuid
            }
            
            // TODO: Remove the enemy's next turn
            
            // If there's no enemies, post a win event
            if battleState.enemies.count == 0 {
                self.push(event: EventType.onBattleWon)
            }
            
        case .turnBegan(let uuid):
            
            guard let actor = battleState.actorWith(uuid: uuid) else { return nil }
            
            switch actor.faction {
                
            case .player:
                // Enqueue the player input required event after anything
                // that was triggered by the turn starting.
                self.push(event: EventType.playerInputRequired, priority: 0, shouldQueue: true)
                
            case .enemies:
                (actor as? Enemy)?.planTurn(state: battleState)
                
            default: return nil
            }
            
            

        case .onBattleWon:
            break
            
        case .onBattleLost:
            // Push a player input required here
            self.push(event: EventType.playerInputRequired)
         
        case .concentrationBroken(_):
            break
            
        }
        
        return e
    }
    
    
}
