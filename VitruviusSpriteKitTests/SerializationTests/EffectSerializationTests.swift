//
//  EffectSerializationTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 10/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit


class EffectSerializationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerialization() {
        
        do {
            
            // Make an array of effects
            let effects = [
                CSDrain.DrainEffect.init(ownerUuid: UUID(), sourceUuid: UUID()).withWrapper(uuid: UUID()),
                EnemyTurnEffect.init(enemyUuid: UUID(), name: "TestName", events: [
                    EventType.attack(AttackEvent.init(sourceUuid: UUID(), sourceOwner: UUID(), targets: [UUID()], amount: 42))
                ]).withWrapper(uuid: UUID()),
                DiscardThenDrawAtEndOfTurnEffect.init(ownerUuid: UUID(), cardsDrawn: 7).withWrapper(uuid: UUID()),
                EventPrinterEffect().withWrapper(uuid: UUID()),
                CSMistForm.MistFormEffect.init(ownerUuid: UUID()).withWrapper(uuid: UUID())
            ]
            
            let data0 = try JSONEncoder().encode(effects)
            let string0 = String(data: data0, encoding: .utf8)!
            
            print(string0)
            
            let effectsDuplication = try JSONDecoder().decode([Effect].self, from: data0)
            
            // Re-serialize this array
            let data1 = try JSONEncoder().encode(effectsDuplication)
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
