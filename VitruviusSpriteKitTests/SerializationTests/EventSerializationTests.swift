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
        
        let events: [Event] = [
            .playerInputRequired,
            .onBattleBegan,
//            .onEnemyPlannedTurn(EnemyTurnEffect.init(uuid: UUID, enemy: <#T##Enemy#>, name: <#T##String#>, events: <#T##[Event]#>)),
            .onTurnBegan(ActorEvent.init(actorUuid: UUID())),
            .onTurnEnded(ActorEvent.init(actorUuid: UUID())),
//            .addEffect(IEffect),
//            .removeEffect(IEffect),
            .willDrawCards(DrawCardsEvent.init(actorUuid: UUID(), amount: 7)),
            .drawCard(ActorEvent.init(actorUuid: UUID())),
            .onCardDrawn(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())),
            .discardCard(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())),
            .discardHand(ActorEvent.init(actorUuid: UUID())),
            .destroyCard(CardEvent.init(actorUuid: UUID(), cardUuid: UUID())),
            .shuffleDiscardIntoDrawPile(ActorEvent.init(actorUuid: UUID())),
            .willLoseHp(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .willLoseBlock(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .didLoseHp(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .didLoseBlock(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .willGainHp(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .willGainBlock(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .didGainHp(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .didGainBlock(UpdateBodyEvent.init(targetActorUuid: UUID(), sourceUuid: UUID(), amount: 7)),
            .playCard(CardEvent.init(actorUuid: UUID(), cardUuid: UUID()), UUID()),
            .attack(AttackEvent.init(sourceUuid: UUID(), sourceOwner: UUID(), targets: [UUID()], amount: 7)),
            .onEnemyDefeated(ActorEvent.init(actorUuid: UUID())),
            .onBattleWon,
            .onBattleLost,
        ]
        
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
