//
//  KnapsackTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 19/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit


class KnapsackTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let x = Knapsack.solve(maxWeight: 3, items: [
            Knapsack.Item.init(elt: "strike-a", cost: 1, value: 3),
            Knapsack.Item.init(elt: "defend", cost: 1, value: 3),
            Knapsack.Item.init(elt: "strike-b", cost: 1, value: 3),
            Knapsack.Item.init(elt: "fireball", cost: 3, value: 40),
            Knapsack.Item.init(elt: "strike-c", cost: 1, value: 3),
        ])
        
        XCTAssertEqual(1, x.count)
        XCTAssertEqual(x.first!, "fireball")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
