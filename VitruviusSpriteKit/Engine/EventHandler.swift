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
    var name: String { get }
    func handle(event: Event, state: BattleState) -> Bool
}

enum Event {
    
    case playerInputRequired
    
    case onBattleBegan
    
    case onEnemyPlannedTurn(EnemyTurnEffect)
    
    case onTurnBegan(PlayerEvent)
    case onTurnEnded(PlayerEvent)
    
    case addEffect(IEffect)
    case removeEffect(IEffect)
    
    case willDrawCards(DrawCardsEvent)
    case drawCard(PlayerEvent)
    case onCardDrawn(CardDrawnEvent)
    case discardCard(DiscardCardEvent)
    case discardHand(PlayerEvent)
    case destroyCard(DiscardCardEvent)
    case shuffleDiscardIntoDrawPile(PlayerEvent)
        
    case willLoseHp(UpdateBodyEvent)
    case willLoseBlock(UpdateBodyEvent)
    case didLoseHp(UpdateBodyEvent)
    case didLoseBlock(UpdateBodyEvent)
    
    case willGainHp(UpdateBodyEvent)
    case willGainBlock(UpdateBodyEvent)
    case didGainHp(UpdateBodyEvent)
    case didGainBlock(UpdateBodyEvent)
    
    case playCard(CardEvent)
    case attack(AttackEvent)
    
    case onEnemyDefeated(Enemy)
    
    case onBattleWon
    case onBattleLost
}

class DiscardCardEvent {
    let actor: Actor
    let card: ICard
    init(actor: Actor, card: ICard) {
        self.actor = actor
        self.card = card
    }
}


class PlayerEvent {
    var actor: Actor
    init(actor: Actor) {
        self.actor = actor
    }
}

class DrawCardsEvent {
    var actor: Actor
    var amount: Int
    init(actor: Actor, amount: Int) {
        self.actor = actor
        self.amount = amount
    }
}

class CardDrawnEvent {
    var actor: Actor
    var card: ICard
    init(actor: Actor, card: ICard) {
        self.actor = actor
        self.card = card
    }
}

class CardEvent {
    var cardOwner: Actor
    var card: ICard
    var target: Actor?
    init(cardOwner: Actor, card: ICard, target: Actor? = nil) {
        self.cardOwner = cardOwner
        self.card = card
        self.target = target
    }
}

class AttackEvent {
    
    let sourceUuid: UUID
    var sourceOwner: Actor
    var targets: [Actor]
    var amount: Int
    
    init(sourceUuid: UUID, sourceOwner: Actor, targets: [Actor], amount: Int) {
        self.sourceUuid = sourceUuid
        self.sourceOwner = sourceOwner
        self.targets = targets
        self.amount = amount
    }
}

class UpdateBodyEvent {
    
    var player: Actor
    let sourceUuid: UUID
    var amount: Int
    
    init(player: Actor, sourceUuid: UUID, amount: Int) {
        self.player = player
        self.sourceUuid = sourceUuid
        self.amount = amount
    }
    
    func with(amount: Int) -> UpdateBodyEvent {
        return UpdateBodyEvent(
            player: self.player,
            sourceUuid: self.sourceUuid,
            amount: amount
        )
    }
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
            self.eventStack.enqueue(elt: Event.willDrawCards(DrawCardsEvent.init(actor: battleState.player, amount: 5)))
            
            // The enemy plans their turns
            let enemyPlansEvents = battleState.enemies.map({ $0.planTurn(state: battleState) })
            self.enqueue(events: enemyPlansEvents)
            
            // Enqueue the turn order
            let enemyTurnsStart = battleState.enemies.map({ Event.onTurnBegan(PlayerEvent.init(actor: $0)) })
            self.enqueue(events: [Event.onTurnBegan(PlayerEvent.init(actor: battleState.player))] + enemyTurnsStart)
            
            
        case .onEnemyPlannedTurn(let effect):
            self.effectList.append(effect)
        
        case .onTurnBegan(let event):
            
            // Lose all your block
            // TODO: We might want to lose less block here
            
            if event.actor.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            
            self.push(
                event: Event.willLoseBlock(
                    UpdateBodyEvent(player: event.actor, sourceUuid: handlerUuid, amount: event.actor.body.block)
                )
            )
        
        case .onTurnEnded(let event):
            
            // Enqueue their next turn...
            self.eventStack.enqueue(elt: Event.onTurnBegan(PlayerEvent(actor: event.actor)))
            
        case .addEffect(let effect):
            self.effectList.insert(effect, at: 0)
            
        case .removeEffect(let effect):
            self.effectList.removeAll { (e) -> Bool in
                e.uuid == effect.uuid
            }
        
        case .drawCard(let event):
            
            guard event.actor.cardZones.drawPile.hasDraw() else {
                guard event.actor.cardZones.discard.isEmpty == false else {
                    // Cannot draw a card or reshuffle so do nothing instead
                    return false
                }
                
                // Reshuffle and then draw again
                self.push(event: Event.drawCard(event))
                self.push(event: Event.shuffleDiscardIntoDrawPile(event))
                return false
            }
            
            // Draw a card
            guard let card = event.actor.cardZones.drawPile.drawRandom() else {
                return false
            }
            
            event.actor.cardZones.hand.cards.append(card)
            self.push(event: Event.onCardDrawn(CardDrawnEvent(actor: event.actor, card: card)))
            
        case .discardCard(let event):
            
            event.actor.cardZones.hand.cards.removeAll { (card) -> Bool in
                card.uuid == event.card.uuid
            }
            event.actor.cardZones.discard.push(elt: event.card)
        
        case .destroyCard(let event):
            break
            
        case .discardHand(let event):
            
            for card in event.actor.cardZones.hand.cards {
                self.push(event: Event.discardCard(DiscardCardEvent.init(actor: event.actor, card: card)))
            }
            
        case .willDrawCards(let drawCardsEvent):
            
            // Enqueue a draw for each in amount
            guard drawCardsEvent.amount > 0 else { return false }
            for _ in 0...drawCardsEvent.amount-1 {
                self.push(event: Event.drawCard(PlayerEvent(actor: drawCardsEvent.actor)))
            }
            
        case .onCardDrawn(let event):
            
            event.card.onDrawn(source: event.actor, battleState: battleState)
            
        case .shuffleDiscardIntoDrawPile(let event):
            
            let discardedCards = event.actor.cardZones.discard.asArray()
            event.actor.cardZones.discard.removeAll()
            event.actor.cardZones.drawPile.shuffleIn(cards: discardedCards)
            
        case .willLoseHp(let bodyEvent):
            // Calculate the amount of lost HP
            let remainingHp = max(bodyEvent.player.body.hp - bodyEvent.amount, 0)
            let lostHp = bodyEvent.player.body.hp - remainingHp
            guard lostHp > 0 else {
                return false
            }
            bodyEvent.player.body.hp -= lostHp
            self.push(event: Event.didLoseHp(bodyEvent))
            
        case .willLoseBlock(let bodyEvent):
            let remainingBlock = max(bodyEvent.player.body.block - bodyEvent.amount, 0)
            let lostBlock = bodyEvent.player.body.block - remainingBlock
            guard lostBlock > 0 else {
                return false
            }
            bodyEvent.player.body.block -= lostBlock
            self.push(event: Event.didLoseBlock(bodyEvent))
            
        case .didLoseHp(let bodyEvent):
            
            // TODO: This is a little dodgey
            if bodyEvent.player.body.hp == 0 {
                if bodyEvent.player.faction == .enemies {
                    self.push(event: Event.onEnemyDefeated(bodyEvent.player as! Enemy))
                } else if bodyEvent.player.faction == .player {
                    self.push(event: Event.onBattleLost)
                }
            }
            
        case .didLoseBlock(let bodyEvent):
            break
            
        case .willGainHp(let bodyEvent):
            // Gain up to your maximum HP
            let nextHp = min(bodyEvent.player.body.hp + bodyEvent.amount, bodyEvent.player.body.maxHp)
            let gainedLife = nextHp - bodyEvent.player.body.hp
            bodyEvent.player.body.hp += gainedLife
            let event = bodyEvent.with(amount: gainedLife)
            self.push(event: Event.didGainHp(event))
            
        case .willGainBlock(let bodyEvent):
            bodyEvent.player.body.block += bodyEvent.amount
            self.push(event: Event.didGainBlock(bodyEvent))
            
        case .didGainHp(let bodyEvent):
            break
            
        case .didGainBlock(let bodyEvent):
            break
            
        case .playCard(let cardEvent):
            if cardEvent.cardOwner.faction == .player {
                self.push(event: Event.playerInputRequired)
            }
            cardEvent.card.resolve(source: cardEvent.cardOwner, battleState: battleState, target: cardEvent.target)
            
        case .attack(let attackEvent):
            
            attackEvent.targets.forEach { (target) in
                
                // Send the event to reduce the block
                
                let updatedBlock = max(target.body.block - attackEvent.amount, 0)
                let blockLost = target.body.block - updatedBlock
                let damageRemaining = attackEvent.amount - blockLost
                
                if damageRemaining > 0 {
                    self.eventStack.push(elt:
                        Event.willLoseHp(
                            UpdateBodyEvent(player: target, sourceUuid: attackEvent.sourceUuid, amount: damageRemaining)
                        )
                    )
                }
                
                self.eventStack.push(elt:
                    Event.willLoseBlock(
                        UpdateBodyEvent(player: target, sourceUuid: attackEvent.sourceUuid, amount: blockLost)
                    )
                )
            }
            
        case .onEnemyDefeated(let enemy):
            
            // Remove the enemy from the list of enemies
            battleState.enemies.removeAll { (e) -> Bool in
                e.uuid == enemy.uuid
            }
            
            
            // Remove the queued start of turn from the queue...
            self.eventStack.removeWhere { (e) -> Bool in
                switch e {
                case .onTurnBegan(let e): return e.actor.uuid == enemy.uuid
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
    var name: String
    let cardsDrawn: Int
    
    init(uuid: UUID, ownerUuid: UUID, name: String, cardsDrawn: Int) {
        self.uuid = uuid
        self.ownerUuid = ownerUuid
        self.name = name
        self.cardsDrawn = cardsDrawn
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
        
        switch event {
            
        case .onTurnEnded(let event):
            
            guard event.actor.uuid == self.ownerUuid else {
                return false
            }
            
            state.eventHandler.push(events: [
                Event.discardHand(PlayerEvent(actor: event.actor)),
                Event.willDrawCards(DrawCardsEvent(actor: event.actor, amount: self.cardsDrawn))
            ])
            
        default:
            break
        }
        
        return false
    }
}


class EventPrinterEffect: IEffect {
    
    var uuid: UUID
    var name: String
    
    init(uuid: UUID, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
        
        print("At \(Date().timeIntervalSince1970)")
        
        switch event {
            
        case .playerInputRequired:
            print("Player input required.")
            
        case .onBattleBegan:
            print("Battle began.")
            
        case .onEnemyPlannedTurn(let e):
            print("\n\(e.enemy.name) planned their next turn.")
            
        case .onTurnBegan(let e):
            print("\n>>> \(e.actor.name) began their turn.")
            
        case .onTurnEnded(let e):
            print("\n<<< \(e.actor.name) ended their turn.")
            
        case .addEffect(let e):
            print("\(e.name) added to effects list.")
            
        case .removeEffect(let e):
            print("\(e.name) removed from effects list.")
            
        case .willDrawCards(let e):
            print("\(e.actor.name) will draw \(e.amount) cards.")
            
        case .drawCard(let e):
            print("\(e.actor.name) drew a card.")
            
        case .onCardDrawn(let e):
            print("\(e.actor.name) drew \(e.card.name) [\(e.card.uuid)].")
            
        case .discardCard(let e):
            print("\(e.actor.name) discarded \(e.card.name)")
            
        case .discardHand(let e):
            print("\(e.actor.name) discards their hand.")
            
        case .destroyCard(let e):
            print("\(e.actor.name) destroys \(e.card.name)")
            
        case .shuffleDiscardIntoDrawPile(let e):
            print("\(e.actor.name) shuffles their discard into their draw pile.")
            
        case .willLoseHp(let e):
            print("\(e.player.name) will lose \(e.amount) hp -> \(e.player.body.description).")
            
        case .willLoseBlock(let e):
            print("\(e.player.name) will lose \(e.amount) block -> \(e.player.body.description).")
            
        case .didLoseHp(let e):
            print("\(e.player.name) lost \(e.amount) hp -> \(e.player.body.description).")
            
        case .didLoseBlock(let e):
            print("\(e.player.name) lost \(e.amount) block -> \(e.player.body.description).")
            
        case .willGainHp(let e):
            print("\(e.player.name) will gain \(e.amount) hp -> \(e.player.body.description).")
            
        case .willGainBlock(let e):
            print("\(e.player.name) will gain \(e.amount) block -> \(e.player.body.description).")
        
        case .didGainHp(let e):
            print("\(e.player.name) gained \(e.amount) hp -> \(e.player.body.description).")
            
        case .didGainBlock(let e):
            print("\(e.player.name) gained \(e.amount) block -> \(e.player.body.description).")
            
        case .playCard(let e):
            print("\n\(e.cardOwner.name) played \(e.card.name).")
            
        case .attack(let e):
            let targetList = e.targets.map({ $0.name }).joined(separator: ", ")
            print("\(e.sourceOwner.name) attacked \(targetList) for \(e.amount).")
            
        case .onEnemyDefeated(let e):
            print("\(e.name) was defeated.")
            
        case .onBattleWon:
            print("\nPlayer won the battle.")
            
        case .onBattleLost:
            print("\nPlayer lost the battle.")
            
        }

        
        return false
    }
    
    
}


