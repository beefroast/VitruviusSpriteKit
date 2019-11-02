//
//  SharpCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CSRecall : CardStrategy {
    
    let cardNumber: Int = 6
    
    var name: String = "Recall"
    var cardText: String { get { return "Draw 3 cards." }}
    var requiresSingleTarget: Bool = false
    
    let rarity: CardRarity = CardRarity.uncommon
    let attributes: CardAttributes = .spell
    let classes: CardClasses = .sharp
    
    func costFor(card: Card) -> Int { return 0 }
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func resolve(card: Card, source: Actor, gameState: GameState, target: Actor?) {
        
        // Pay for the card
        gameState.currentBattle!.eventHandler.push(event: EventType.turnBegan(source.uuid), priority: self.costFor(card: card))
        
        gameState.currentBattle!.eventHandler.push(events: [
            EventType.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            EventType.willDrawCards(DrawCardsEvent.init(actorUuid: source.uuid, amount: 3))
        ])
        
    }
    
    func onDrawn(card: Card, source: Actor, gameState: GameState) {}
    func onDiscarded(card: Card, source: Actor, gameState: GameState) {}
}

class CSFireball: CardStrategy {
    
    let cardNumber: Int = 7
    
    var name: String = "Fireball"
    var cardText: String { get { return "Channel. Then deal 8 damage to each enemy." }}
    var requiresSingleTarget: Bool = false

    let rarity: CardRarity = CardRarity.basic
    let attributes: CardAttributes = [.attack, .spell]
    let classes: CardClasses = .sharp
    
    func textFor(card: Card) -> String {
        self.cardText
    }
    
    func costFor(card: Card) -> Int { return card.level > 0 ? 4 : 3 }
        
    func resolve(card: Card, source: Actor, gameState: GameState, target: Actor?) {
        
        guard let battleState = gameState.currentBattle else {
            return
        }
        
        let event = CSFireballEvent.init(uuid: UUID(), sourceUuid: card.uuid, sourceOwner: source.uuid, damage: 8)
        let channelEffect = event.channelEffect().withEffect(uuid: UUID(), owner: source.uuid)
        
        battleState.eventHandler.push(events: [
            EventType.discardCard(CardEvent.init(actorUuid: source.uuid, cardUuid: card.uuid)),
            EventType.addEffect(channelEffect)
        ])
        
        battleState.eventHandler.push(
            event: EventType.chanelledEvent(event),
            priority: self.costFor(card: card)
        )
    }
    
    func onDrawn(card: Card, source: Actor, gameState: GameState) {}
    func onDiscarded(card: Card, source: Actor, gameState: GameState) {}
    
    class CSFireballEvent: ChannelledEvent {
        
        let uuid: UUID
        let sourceUuid: UUID
        let sourceOwner: UUID
        let damage: Int
        
        init(
            uuid: UUID,
            sourceUuid: UUID,
            sourceOwner: UUID,
            damage: Int
        ) {
            self.uuid = uuid
            self.sourceUuid = sourceUuid
            self.sourceOwner = sourceOwner
            self.damage = damage
        }
        
        func onChannelled(battleState: BattleState) {
            battleState.eventHandler.push(
                event: EventType.attack(
                    AttackEvent.init(
                        sourceUuid: sourceUuid,
                        sourceOwner: sourceOwner,
                        targets: battleState.enemies.map({ $0.uuid }),
                        amount: damage
                    )
                )
            )
        }
    }

    
}

protocol ChannelledEvent {
    var uuid: UUID { get }
    var sourceUuid: UUID { get }
    var sourceOwner: UUID { get }
    func onChannelled(battleState: BattleState)
}

extension ChannelledEvent {
    func channelEffect() -> EChannel {
        return EChannel.init(actorUuid: self.sourceOwner, eventUuid: uuid)
    }
}
