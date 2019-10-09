//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation






protocol IEffect {
    var uuid: UUID { get }
    var effectName: String { get }
    func handle(event: Event, state: BattleState) -> Bool
}



class EventHandler {
    
    let handlerUuid: UUID = UUID()
    var eventStack: StackQueue<Event>
    private var effectList: [IEffect]
    
    init(eventStack: StackQueue<Event>, effectList: [IEffect]) {
        self.eventStack = eventStack
        self.effectList = effectList
    }
    
    func push(events: [Event]) -> Void {
        for e in events.reversed() { eventStack.push(elt: e) }
    }
    
    func enqueue(events: [Event]) -> Void {
        for e in events { eventStack.enqueue(elt: e) }
    }
    
    func push(event: Event) -> Void {
        eventStack.push(elt: event)
    }
    
    func appendToEffectsList(effect: IEffect) {
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
        let playerInputRequired = self.handle(event: e, battleState: battleState)
        return playerInputRequired
    }
    
    func handle(event: Event, battleState: BattleState) -> Bool {
        
        // Loop through the effect list
        self.effectList.removeAll { (effect) -> Bool in
            effect.handle(event: event, state: battleState)
        }
    
        switch event {
            
        case .playerInputRequired:
            return true
            
        case .onBattleBegan:
            
            // The player draws their hand
            self.eventStack.enqueue(elt: Event.willDrawCards(DrawCardsEvent.init(actorUuid: battleState.player.uuid, amount: 5)))
            
            // The enemy plans their turns
            let enemyPlansEvents = battleState.enemies.map({ $0.planTurn(state: battleState) })
            self.enqueue(events: enemyPlansEvents)
            
            // Enqueue the turn order
            let enemyTurnsStart = battleState.enemies.map({ Event.onTurnBegan(ActorEvent.init(actorUuid: $0.uuid)) })
            self.enqueue(events: [Event.onTurnBegan(ActorEvent.init(actorUuid: battleState.player.uuid))] + enemyTurnsStart)
            
        case .onEnemyPlannedTurn(let e):
            self.effectList.append(e)
        
        case .onTurnBegan(let e):
            
            guard let actor = battleState.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            if actor.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            
            self.push(event:
                Event.willLoseBlock(UpdateBodyEvent.init(
                    targetActorUuid: e.actorUuid,
                    sourceUuid: handlerUuid,
                    amount: actor.body.block)))
        
        case .onTurnEnded(let e):
            self.eventStack.enqueue(
                elt: Event.onTurnBegan(ActorEvent.init(actorUuid: e.actorUuid))
            )
            
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
            guard let card = actor.cardZones.drawPile.drawRandom() else {
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
            break
            
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
            
            card.onDrawn(source: actor, battleState: battleState)
            
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
            
        case .playCard(let e):
            
            guard let actor = battleState.actorWith(uuid: e.0.actorUuid) else {
                break
            }
            
            if actor.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            
            guard let card = actor.cardZones.hand.cardWith(uuid: e.0.cardUuid) else {
                break
            }
            
            card.resolve(
                source: actor,
                battleState: battleState,
                target: e.1.flatMap({ battleState.actorWith(uuid: $0) })
            )
            
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
                    self.eventStack.push(elt:
                        Event.willLoseHp(UpdateBodyEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: damageRemaining))
                    )
                }
                
                self.eventStack.push(elt:
                    Event.willLoseBlock(
                        UpdateBodyEvent.init(targetActorUuid: targetUuid, sourceUuid: e.sourceUuid, amount: blockLost)
                    )
                )
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
}


class DiscardThenDrawAtEndOfTurnEffect: IEffect {
    
    var uuid: UUID
    let ownerUuid: UUID
    var effectName: String
    let cardsDrawn: Int
    
    init(uuid: UUID, ownerUuid: UUID, name: String, cardsDrawn: Int) {
        self.uuid = uuid
        self.ownerUuid = ownerUuid
        self.effectName = name
        self.cardsDrawn = cardsDrawn
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
        
        switch event {
            
        case .onTurnEnded(let e):
            
            guard let actor = state.actorWith(uuid: e.actorUuid) else {
                return false
            }
            
            guard actor.uuid == self.ownerUuid else {
                return false
            }
            
            state.eventHandler.push(events: [
                Event.discardHand(ActorEvent.init(actorUuid: e.actorUuid)),
                Event.willDrawCards(DrawCardsEvent.init(actorUuid: e.actorUuid, amount: 5))
            ])
            
        default:
            break
        }
        
        return false
    }
}


class EventPrinterEffect: IEffect {
    
    var uuid: UUID
    var effectName: String
    
    init(uuid: UUID, name: String) {
        self.uuid = uuid
        self.effectName = name
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
                
        switch event {
            
        case .playerInputRequired:
            print("Player input required.")
            
        case .onBattleBegan:
            print("Battle began.")
            
        case .onEnemyPlannedTurn(let e):
            let nameOrUuid = state.actorWith(uuid: e.enemyUuid)?.name ?? e.enemyUuid.uuidString
            print("\n\(nameOrUuid) planned their next turn.")
            
        case .onTurnBegan(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\n>>> \(nameOrUuid) began their turn.")
            
        case .onTurnEnded(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\n<<< \(nameOrUuid) ended their turn.")
            
        case .addEffect(let e):
            print("\(e.effectName) added to effects list.")
            
        case .removeEffect(let e):
            print("\(e.effectName) removed from effects list.")
            
        case .willDrawCards(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) will draw \(e.amount) cards.")
            
        case .drawCard(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) drew a card.")
            
        case .onCardDrawn(let e):
            let actor = state.actorWith(uuid: e.actorUuid)
            let cardName = actor?.cardZones.hand.cardWith(uuid: e.cardUuid)?.name ?? e.cardUuid.uuidString
            let nameOrUuid = actor?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) drew \(cardName).")
            
        case .discardCard(let e):
            let actor = state.actorWith(uuid: e.actorUuid)
            let cardName = actor?.cardZones.hand.cardWith(uuid: e.cardUuid)?.name ?? e.cardUuid.uuidString
            let nameOrUuid = actor?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) discarded \(cardName).")
            
        case .discardHand(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) discards their hand.")
            
        case .destroyCard(let e):
            let actor = state.actorWith(uuid: e.actorUuid)
            let cardName = actor?.cardZones.hand.cardWith(uuid: e.cardUuid)?.name ?? e.cardUuid.uuidString
            let nameOrUuid = actor?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) destroyed \(cardName).")
            
        case .shuffleDiscardIntoDrawPile(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.uuidString
            print("\(nameOrUuid) shuffles their discard into their draw pile.")
            
        case .willLoseHp(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) will lose \(e.amount) hp.")
            
        case .willLoseBlock(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) will lose \(e.amount) block.")
            
        case .didLoseHp(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) lost \(e.amount) hp.")
            
        case .didLoseBlock(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) lost \(e.amount) block.")
            
        case .willGainHp(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) will gain \(e.amount) hp.")
            
        case .willGainBlock(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) will gain \(e.amount) block.")
        
        case .didGainHp(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) gained \(e.amount) hp.")
            
        case .didGainBlock(let e):
            let nameOrUuid = state.actorWith(uuid: e.targetActorUuid)?.name ?? e.targetActorUuid.description
            print("\(nameOrUuid) gained \(e.amount) block.")
            
        case .playCard(let e):
            let actor = state.actorWith(uuid: e.0.actorUuid)
            let cardName = actor?.cardZones.hand.cardWith(uuid: e.0.cardUuid)?.name ?? e.0.cardUuid.uuidString
            let nameOrUuid = actor?.name ?? e.0.actorUuid.uuidString
            print("\n\(nameOrUuid) played \(cardName).")
            
        case .attack(let e):
            let nameOrUuid = state.actorWith(uuid: e.sourceOwner)?.name ?? e.sourceOwner.description
            let targetList = e.targets
                .compactMap({ state.actorWith(uuid: $0) })
                .map({ $0.name })
                .joined(separator: ",")
            print("\(nameOrUuid) attacked \(targetList) for \(e.amount).")
            
        case .onEnemyDefeated(let e):
            let nameOrUuid = state.actorWith(uuid: e.actorUuid)?.name ?? e.actorUuid.description
            print("\(nameOrUuid) was defeated.")
            
        case .onBattleWon:
            print("\nPlayer won the battle.")
            
        case .onBattleLost:
            print("\nPlayer lost the battle.")
            
        }

        
        return false
    }
    
    
}


