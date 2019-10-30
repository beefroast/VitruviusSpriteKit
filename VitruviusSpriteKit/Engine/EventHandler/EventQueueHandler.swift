//
//  EventQueue.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 30/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class EventQueueHandler {
    
    private var eventQueue: PriorityQueue<Event>
    private var effectList: PriorityQueue<Effect>
    
    init(
        eventQueue: PriorityQueue<Event> = PriorityQueue(),
        effectList: PriorityQueue<Effect> = PriorityQueue()) {
        self.eventQueue = eventQueue
        self.effectList = effectList
    }
    
    func push(event: Event, priority: Int = 0) -> Int {
        return self.eventQueue.insert(element: event, priority: priority)
    }
    
    func push(events: [Event]) {
        for e in events.reversed() {
            _ = self.eventQueue.insert(element: e, priority: 0)
        }
    }
    
    func popAndHandle(state: GameState) -> Void {
        
        guard let e = self.eventQueue.popNext() else {
            return
        }
        
        var isEventConsumed: Bool = false
        
        self.effectList.removeWhere { (effect) -> Bool in
            guard isEventConsumed == false else { return false }
            let result = effect.handle(event: e, gameState: state)
            isEventConsumed = result.consumeEvent
            return result.consumeEffect
        }
    }
    
}
