//
//  BattleStateSerializationTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 15/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit

class BattleStateSerializationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBattleStateSerialization() {
        
          let player = Player(
              uuid: UUID(),
              name: "Player",
              faction: .player,
              body: Body(block: 0, hp: 72, maxHp: 72),
              cardZones: CardZones(
                  hand: Hand.newEmpty(),
                  drawPile: DrawPile.init(cards: [
                      CardStrike().instance(),
                      CardStrike().instance(),
                      CardStrike().instance(),
                      CardStrike().instance(),
                      CardDefend().instance(),
                      CardDefend().instance(),
                      CardDefend().instance(),
                      CardDefend().instance(),
                      CardFireball().instance(),
                      CardRecall().instance(),
                      
                  ]),
                  discard: DiscardPile()
              ),
              currentMana: 3,
              maxMana: 3
          )
          
          
          let goomba = Enemy(
               uuid: UUID(),
               name: "Goomba",
               faction: .enemies,
               body: Body(block: 0, hp: 40, maxHp: 40),
               cardZones: CardZones(
                  hand: Hand.newEmpty(),
                  drawPile: DrawPile.newEmpty(),
                   discard: DiscardPile()
               ),
               enemyStrategy: CrabEnemyStrategy()
           )
           
           
           let koopa = Enemy(
               uuid: UUID(),
               name: "Koopa",
               faction: .enemies,
               body: Body(block: 0, hp: 40, maxHp: 40),
               cardZones: CardZones(
                  hand: Hand.newEmpty(),
                   drawPile: DrawPile.newEmpty(),
                   discard: DiscardPile()
               ),
               enemyStrategy: CrabEnemyStrategy()
           )
          
          let battleState = BattleState.init(
              player: player,
              allies: [],
              enemies: [goomba, koopa],
              eventHandler: EventHandler(
                  uuid: UUID(),
                  eventStack: StackQueue<Event>(),
                  effectList: [
                      EventPrinterEffect.init().withWrapper(uuid: UUID())
                  ]
              ),
              rng: RandomNumberGenerator(count: 0, seed: 0)
          )
                  
          battleState.eventHandler.push(event:
              Event.addEffect(
                  DiscardThenDrawAtEndOfTurnEffect(
                      ownerUuid: player.uuid, cardsDrawn: 5
                  ).withWrapper(uuid: UUID())
              )
          )
        
        
        do {

            let data0 = try JSONEncoder().encode(battleState)
            let string0 = String(data: data0, encoding: .utf8)!
            
            print(string0)
            
            let dupe = try JSONDecoder().decode(BattleState.self, from: data0)
            
            // Re-serialize the object
            let data1 = try JSONEncoder().encode(dupe)
            let string1 = String(data: data1, encoding: .utf8)!
            
            // Compare these strings
            XCTAssertEqual(string0, string1)
            
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
