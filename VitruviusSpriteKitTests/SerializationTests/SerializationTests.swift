//
//  SerializationTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 9/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit


class SerializationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let cards = [
            CardStrike().instance(),
            CardDefend().instance()
        ]
        
        do {
            let data = try JSONEncoder().encode(cards)
            let string = String(data: data, encoding: .utf8)
            let decoded = try JSONDecoder().decode(Array<Card>.self, from: data)
            
            zip(cards, decoded).forEach { (pair) in
                let a = pair.0
                let b = pair.1
                XCTAssertEqual(a.uuid, b.uuid)
                XCTAssertEqual(a.card.name, b.card.name)
            }
              
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
