//
//  EventTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 9/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


import XCTest
@testable import VitruviusSpriteKit

class EventTests: XCTestCase {

    var battleState: BattleState!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        let player = Player.init(
            uuid: UUID(),
            name: "Test Player",
            faction: .player,
            body: Body.init(block: 0, hp: 10, maxHp: 10),
            cardZones: CardZones.newEmpty(),
            currentMana: 3,
            maxMana: 3
        )
        
        let enemy = Enemy(
            uuid: UUID(),
            name: "Enemy",
            faction: .player,
            body: Body.init(
                block: 0,
                hp: 10,
                maxHp: 10
            ),
            cardZones: CardZones.newEmpty()
        )
        
        self.battleState = BattleState(
            player: player,
            allies: [],
            enemies: [enemy],
            eventHandler: EventHandler.init(
                uuid: UUID(),
                eventStack: StackQueue<Event>(),
                effectList: [
                    EventPrinterEffect.init().withWrapper(uuid: UUID())
                ]
            )
        )
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func addEventAndRunUntilDone(event: Event) -> Void {
        
        // Push the player input event so that we stop once we've applied everything
        self.battleState.eventHandler.push(event: Event.playerInputRequired)
        
        // Push the event under testing
        self.battleState.eventHandler.push(event: event)
        
        // Pop the stack until we need player input again
        self.battleState.eventHandler.flushEvents(battleState: self.battleState)
    }
    
    
    func testGainBlock() {

        self.addEventAndRunUntilDone(event: Event.willGainBlock(
            UpdateBodyEvent.init(
                targetActorUuid: self.battleState.player.uuid,
                sourceUuid: UUID(),
                amount: 10
            )
        ))
        
        // Make sure we've gained 10 block
        XCTAssertEqual(self.battleState.player.body.block, 10)
    }
    
    func testLoseBlock() {

         // Gain 10 block...
         self.addEventAndRunUntilDone(event: Event.willGainBlock(
             UpdateBodyEvent.init(
                 targetActorUuid: self.battleState.player.uuid,
                 sourceUuid: UUID(),
                 amount: 10
             )
         ))
        
        // Now lose 6 block
        self.addEventAndRunUntilDone(event: Event.willLoseBlock(
            UpdateBodyEvent.init(
                targetActorUuid: self.battleState.player.uuid,
                sourceUuid: UUID(),
                amount: 6
            )
        ))
         
         // Should have 4 block now
         XCTAssertEqual(self.battleState.player.body.block, 4)
                 
    }
    
    func testLoseHp() {
        
        // Lose 6 hp
        self.addEventAndRunUntilDone(event: Event.willLoseHp(
            UpdateBodyEvent.init(
                targetActorUuid: self.battleState.player.uuid,
                sourceUuid: UUID(),
                amount: 6
            )
        ))
          
        // Should have 4 hp now
        XCTAssertEqual(self.battleState.player.body.hp, 4)
        
    }
    
    func testGainHp() {
        
        // Lose 8 hp
        self.addEventAndRunUntilDone(event: Event.willLoseHp(
            UpdateBodyEvent.init(
                targetActorUuid: self.battleState.player.uuid,
                sourceUuid: UUID(),
                amount: 8
            )
        ))
        
        // Gain 5 hp
        self.addEventAndRunUntilDone(event: Event.willGainHp(
            UpdateBodyEvent.init(
                targetActorUuid: self.battleState.player.uuid,
                sourceUuid: UUID(),
                amount: 5
            )
        ))
          
        // Should have 7 hp now
        XCTAssertEqual(self.battleState.player.body.hp, 7)
        
    }
    



}
