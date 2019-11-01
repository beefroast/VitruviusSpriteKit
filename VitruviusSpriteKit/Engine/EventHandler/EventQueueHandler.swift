//
//  EventQueue.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class EventQueueHandler: Codable {
    
    private var eventQueue: PriorityQueue<Event>
    private var effectList: PriorityQueue<Effect>
    
    init(
        eventQueue: PriorityQueue<Event> = PriorityQueue(),
        effectList: PriorityQueue<Effect> = PriorityQueue()) {
        self.eventQueue = eventQueue
        self.effectList = effectList
    }
    
    func push(event: Event, priority: Int = 0) {
        _ = self.eventQueue.insert(element: event, priority: priority)
    }
    
    func push(events: [Event]) {
        for e in events.reversed() {
            _ = self.eventQueue.insert(element: e, priority: 0)
        }
    }
    
    func popAndHandle(state: GameState) -> Void {
        
        guard let battleState = state.currentBattle else { return }
        guard let e = self.eventQueue.popNext() else { return }
        
        var isEventConsumed: Bool = false
        
        self.effectList.removeWhere { (effect) -> Bool in
            guard isEventConsumed == false else { return false }
            let result = effect.handle(event: e, gameState: state)
            isEventConsumed = result.consumeEvent
            return result.consumeEffect
        }
        
        // If the event was consumed, we no longer handle it here
        if isEventConsumed { return }
        
        switch e {
            
        case .tick:
            self.eventQueue.forEach { (e) in
                e.priority -= 1
            }
                
        case .playerInputRequired:
            break
            
        case .onBattleBegan:
            
            // Enemies plan their turns
            
            battleState.enemies.forEach { (enemy: Enemy) in
                enemy.planTurn(state: battleState)
            }
            
            // The player draws their hand
            _ = self.push(event: Event.willDrawCards(DrawCardsEvent.init(actorUuid: battleState.player.uuid, amount: 5)))
            
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
                    return
                }
                
                // Reshuffle and then draw again
                self.push(events: [
                    Event.shuffleDiscardIntoDrawPile(ActorEvent.init(actorUuid: e.actorUuid)),
                    Event.drawCard(ActorEvent.init(actorUuid: e.actorUuid))
                ])
                return
            }
            
            // Draw a card
            guard let card = actor.cardZones.drawPile.drawRandom(rng: battleState.rng.drawRng) else {
                return
            }
            
            // Put the card in their hand
            actor.cardZones.hand.cards.append(card)
            _ = self.push(event: Event.onCardDrawn(CardEvent.init(actorUuid: actor.uuid, cardUuid: card.uuid)))
            
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
                return
            }
            
            // TODO: In the future we might want more than one upgrade
            card.level += 1
            
        case .discardHand(let e):
            let player = battleState.player
            self.push(events:
                player.cardZones.hand.cards.map({
                    Event.discardCard(CardEvent.init(actorUuid: player.uuid, cardUuid: $0.uuid))
                })
            )
            
        case .willDrawCards(let e):
            
            // Enqueue a draw for each in amount
            guard e.amount > 0 else { return }
            for _ in 0...e.amount-1 {
                _ = self.push(event: Event.drawCard(ActorEvent(actorUuid: e.actorUuid)))
            }
            
        case .onCardDrawn(let e):
            let actor = battleState.player
            
            guard let card = actor.cardZones.hand.cards.first(where: { (c) -> Bool in
                c.uuid == e.cardUuid
            }) else {
                return
            }
            
        case .shuffleDiscardIntoDrawPile(let e):
            let actor = battleState.player

            let discardedCards = actor.cardZones.discard.asArray()
            actor.cardZones.discard.removeAll()
            actor.cardZones.drawPile.shuffleIn(cards: discardedCards)
            
        case .willLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return
            }
            
            // Calculate the amount of lost HP
            let remainingHp = max(actor.body.hp - e.amount, 0)
            let lostHp = actor.body.hp - remainingHp
            guard lostHp > 0 else {
                return
            }
            actor.body.hp -= lostHp
            self.push(event: Event.didLoseHp(e.with(amount: lostHp)))
            
        case .willLoseBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return
            }
            
            // Calculate the amount of lost block
            let remainingBlock = max(actor.body.block - e.amount, 0)
            let lostBlock = actor.body.block - remainingBlock
            guard lostBlock > 0 else {
                return
            }
            actor.body.block -= lostBlock
            self.push(event: Event.didLoseBlock(e.with(amount: lostBlock)))
            
        case .didLoseHp(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return
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
                return
            }
            
            // Gain up to your maximum HP
            let nextHp = min(actor.body.hp + e.amount, actor.body.maxHp)
            let gainedLife = nextHp - actor.body.hp
            actor.body.hp += gainedLife
            let event = e.with(amount: gainedLife)
            self.push(event: Event.didGainHp(event))
            
        case .willGainBlock(let e):
            
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) else {
                return
            }
            
            actor.body.block += e.amount
            self.push(event: Event.didGainBlock(e))
            
        case .didGainHp(let e):
            break
            
        case .didGainBlock(let e):
            break
            
        case .willGainMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return
            }
            actor.currentMana += e.amount
            
        case .willLoseMana(let e):
            guard let actor = battleState.actorWith(uuid: e.targetActorUuid) as? Player else {
                return
            }
            actor.currentMana = max(actor.currentMana - e.amount, 0)
            
        case .playCard(let e):
            
            let player = battleState.player

            guard let card = player.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                return
            }
            
            // Pay for the card
            self.push(event: Event.playerInputRequired, priority: card.cost)
            
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
            
            // TODO: Remove the enemy's next turn
            
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
    }
    
}
