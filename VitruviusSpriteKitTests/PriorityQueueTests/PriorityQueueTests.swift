//
//  PriorityQueueTests.swift
//  VitruviusSpriteKitTests
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import XCTest
@testable import VitruviusSpriteKit

class PriorityQueueTests: XCTestCase {

    func testInsert() {

        let queue: PriorityQueue<String> = PriorityQueue()

        XCTAssertEqual(queue.insert(element: "A", priority: 0), 0)
        XCTAssertEqual(queue.insert(element: "B", priority: 1), 1)
        XCTAssertEqual(queue.insert(element: "C", priority: 0), 0)
        XCTAssertEqual(queue.insert(element: "D", priority: 99), 3)
        XCTAssertEqual(queue.insert(element: "D", priority: 1), 2)
        
        print(queue.toArray().map({ $0.element }))
        
    }
    
    func testRemove() {
        
        let queue: PriorityQueue<String> = PriorityQueue()

        _ = queue.insert(element: "A", priority: 0)
        _ = queue.insert(element: "B", priority: 1)
        _ = queue.insert(element: "C", priority: 0)
        _ = queue.insert(element: "D", priority: 99)
        _ = queue.insert(element: "D", priority: 1)
        
        queue.removeWhere { (s) -> Bool in
            s == "C"
        }
        
        XCTAssertEqual(queue.toArray().count, 4)
        
        
    }

}
