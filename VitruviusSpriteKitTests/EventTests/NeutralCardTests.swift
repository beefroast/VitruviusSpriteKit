//
//  NeutralCardTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 9/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit


class NeutralCardTests: XCTestCase {

    var battleState: BattleState!
    
    override func setUp() {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let player = Player(
            uuid: UUID(),
            name: "Player",
            faction: .player,
            body: Body.init(
                block: 0,
                hp: 10,
                maxHp: 10
            ),
            cardZones: CardZones.init(
                hand: Hand.init(),
                drawPile: DrawPile.init(cards: []),
                discard: DiscardPile.init()
            ),
            currentMana: 3,
            maxMana: 3
        )
                
        let enemy = Enemy(
            uuid: UUID(),
            name: "Goomba",
            faction: .enemies,
            body: Body(block: 0, hp: 10, maxHp: 10),
            cardZones: CardZones(
               hand: Hand.newEmpty(),
               drawPile: DrawPile.newEmpty(),
                discard: DiscardPile()
            )
        )
                
        self.battleState = BattleState(
            player: player,
            allies: [],
            enemies: [enemy],
            eventHandler: EventHandler.init(
                uuid: UUID(),
                eventStack: StackQueue<Event>(),
                effectList: [
                    EventPrinterEffect().withWrapper(uuid: UUID())
                ]
            ),
            rng: RandomNumberGenerator(count: 0, seed: 0)
        )
    }
    
    func addEventAndRunUntilDone(event: Event) -> Void {
        
        // Push the player input event so that we stop once we've applied everything
        self.battleState.eventHandler.push(event: Event.playerInputRequired)
        
        // Push the event under testing
        self.battleState.eventHandler.push(event: event)
        
        // Pop the stack until we need player input again
        self.battleState.eventHandler.flushEvents(battleState: self.battleState)
    }
    
    
        
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCardStrike() {
        
        // Push the player input event so that we stop once we've applied everything
        self.battleState.eventHandler.push(event: Event.playerInputRequired)
        
        let c = CardStrike()
        
        c.resolve(
            cardUuid: UUID(),
            source: self.battleState.player,
            battleState: self.battleState,
            target: self.battleState.enemies.first
        )
        
        // Pop the stack until we need player input again
        self.battleState.eventHandler.flushEvents(battleState: self.battleState)
        
        XCTAssertEqual(self.battleState.enemies.first!.body.hp, 4)
    }
    
    


}
