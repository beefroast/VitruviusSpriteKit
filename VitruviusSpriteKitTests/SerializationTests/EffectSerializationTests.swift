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
        
        let x = CardMistForm.MistFormEffect.init(ownerUuid: UUID()).withWrapper(uuid: UUID())
        
        let dat = try! JSONEncoder().encode(x)
        let s = String(data: dat, encoding: .utf8)
        
        print(s)
        
        // TODO: Test decoding
        
        let dingus = try! JSONDecoder().decode(Effect.self, from: dat)
        
        
        print("yay")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
