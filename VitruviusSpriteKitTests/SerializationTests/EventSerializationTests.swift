//
//  EventSerializationTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 9/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit

class EventSerializationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEventSerialization() {
        
        var events: [Event] = []
        
        // TODO: Need to work out how to serialize effects, probably similiar to what we're doing with
        // cards.
        
        events.append(.playerInputRequired)
        events.append(.onBattleBegan)
        
        events.append(.onEnemyPlannedTurn(EnemyTurnEffect.init(enemyUuid: UUID(), name: "Goomba's Turn", events: [
            Event.onTurnBegan(ActorEvent.init(actorUuid: UUID()))
        ])))

        events.append(.onTurnBegan(ActorEvent.init(actorUuid: UUID())))
        events.append(.onTurnEnded(ActorEvent.init(actorUuid: UUID())))
//        events.append(.addEffect(HandleEffectStrategy))
//        events.append(.removeEffect(HandleEffectStrategy))
        events.append(.willDrawCards(DrawCardsEvent.init(actorUuid: UUID(), amount: 7)))
        events.append(.drawCard(ActorEvent.init(actorUuid: UUID())))
        events.append(.onCardDrawn(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())))
        events.append(.discardCard(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())))
        events.append(.discardHand(ActorEvent.init(actorUuid: UUID())))
        events.append(.destroyCard(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())))
        events.append(.shuffleDiscardIntoDrawPile(ActorEvent.init(actorUuid: UUID())))
        events.append(.willLoseHp(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.willLoseBlock(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.didLoseHp(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.didLoseBlock(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.willGainHp(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.willGainBlock(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.didGainHp(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.didGainBlock(UpdateAmountEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)))
        events.append(.playCard(PlayCardEvent.init(actorUuid: UUID(), cardUuid: UUID(), target: UUID())))
        events.append(.attack(AttackEvent.init(sourceUuid: UUID(), sourceOwner: UUID(), targets: [UUID()], amount: 7)))
        events.append(.onEnemyDefeated(ActorEvent.init(actorUuid: UUID())))
        events.append(.onBattleWon)
        events.append(.onBattleLost)
        
        
        do {
            
            let data = try JSONEncoder().encode(events)
             let s = String(data: data, encoding: .utf8)
             
             print(s)

             let deserializedArray = try JSONDecoder().decode([Event].self, from: data)
             
             zip(events, deserializedArray).forEach { (eventPair) in
                 let originalEvent = eventPair.0
                 let deserializedEvent = eventPair.1
                 
                 // TODO: Compare the events and make sure that they're the same
             }
            
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
        
 
     
    }

}
