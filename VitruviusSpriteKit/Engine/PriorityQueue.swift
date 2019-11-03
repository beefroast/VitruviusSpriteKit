//
//  PriorityQueue.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class PriorityQueueElement<T>: Codable where T: Codable {
    
    let element: T
    var priority: Int
    var next: PriorityQueueElement<T>? = nil
    
    init(element: T, priority: Int) {
        self.element = element
        self.priority = priority
    }
    
    func insert(elt: PriorityQueueElement<T>, insertedIndex: inout Int) -> PriorityQueueElement {
        if elt.priority <= self.priority {
            elt.next = self
            return elt
        } else {
            insertedIndex += 1
            self.next = self.next?.insert(elt: elt, insertedIndex: &insertedIndex) ?? elt
            return self
        }
    }
    
    func forEach(fn: (PriorityQueueElement<T>) -> Void) {
        fn(self)
        self.next?.forEach(fn: fn)
    }
    
    func removeWhere(fn: (T) -> Bool) -> PriorityQueueElement<T>? {
        if fn(self.element) {
            return self.next
        } else {
            self.next = self.next?.removeWhere(fn: fn)
            return self
        }
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case priority
        case element
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.priority = try values.decode(Int.self, forKey: .priority)
        self.element = try values.decode(T.self, forKey: .element)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.element, forKey: .element)
    }
    
    
}

class NoisyPriorityQueue<T>: PriorityQueue<T> where T: Codable {
    
    func printSelf() {
        print("===QUEUE")
        self.toArray().forEach { (elt) in
            print("[\(elt.priority)] \(elt.element)")
        }
        print("===ENDQUEUE")
    }
    
    override func insert(element: T, priority: Int = 0) -> Int {
        let x = super.insert(element: element, priority: priority)
        printSelf()
        return x
    }
    
    override func popNext() -> T? {
        let x = super.popNext()
        printSelf()
        return x
    }
    
    override func removeWhere(fn: (T) -> Bool) {
        super.removeWhere(fn: fn)
        printSelf()
    }
    
}

class PriorityQueue<T>: Codable where T: Codable {

    var head: PriorityQueueElement<T>? = nil
    
    init() {}
    
    func insert(element: T, priority: Int = 0) -> Int {
        var insertedIndex = 0
        let elt = PriorityQueueElement(element: element, priority: priority)
        self.head = self.head?.insert(elt: elt, insertedIndex: &insertedIndex) ?? elt
        return insertedIndex
    }
    
    func withInserted(element: T, priority: Int = 0) -> PriorityQueue<T> {
        _ = insert(element: element, priority: priority)
        return self
    }
    
    func popNext() -> T? {
        let value = self.head?.element
        self.head = self.head?.next
        return value
    }

    func forEach(fn: (PriorityQueueElement<T>) -> Void) {
        head?.forEach(fn: fn)
    }
    
    func removeWhere(fn: (T) -> Bool) {
        self.head = head?.removeWhere(fn: fn)
    }
    
    func toArray() -> [PriorityQueueElement<T>] {
        var result: [PriorityQueueElement<T>] = []
        head?.forEach(fn: { (elt) in result.append(elt) })
        return result
    }
    
    // MARK: - Codable Implementation

    
    private enum CodingKeys: String, CodingKey {
        case elements
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let elementsAsArray = try values.decode([PriorityQueueElement<T>].self, forKey: .elements)
        elementsAsArray.forEachPair { (x, y) in x.next = y }
        self.head = elementsAsArray.first
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.toArray(), forKey: .elements)
    }
}

extension Array {
    func forEachPair(fn: (Element, Element) -> Void) {
        var last: Element? = nil
        self.forEach { (elt) in
            if let x = last {
                fn(x, elt)
            }
            last = elt
        }
    }
}
