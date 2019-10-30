//
//  PriorityQueue.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class PriorityQueueElement<T> {
    
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
}

class PriorityQueue<T> {

    var head: PriorityQueueElement<T>? = nil
    
    func insert(element: T, priority: Int) -> Int {
        var insertedIndex = 0
        let elt = PriorityQueueElement(element: element, priority: priority)
        self.head = self.head?.insert(elt: elt, insertedIndex: &insertedIndex) ?? elt
        return insertedIndex
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
    
}

