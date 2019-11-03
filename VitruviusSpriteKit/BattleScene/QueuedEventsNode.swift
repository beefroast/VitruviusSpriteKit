//
//  QueuedEventsNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 2/11/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit

class QueuedEventsNode: SKNode {
    
    var turnBeginsNodes: [TurnBeginsNode] = []
    
    override init() {
        super.init()
        
        // MAKE SOME TICKS
        for i in (0...20) {
            let node = SKSpriteNode(color: UIColor.black, size: CGSize.init(width: 4, height: 4))
            self.addChild(node)
            node.position = CGPoint.init(x: i*30, y: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupTurnBeginsNodes(actors: [ActorNode]) -> Void {
        self.turnBeginsNodes = actors.map({ (actorNode) -> TurnBeginsNode in
            let n = TurnBeginsNode.init(actorUuid: actorNode.actorUuid!)
            n.spriteNode?.texture = actorNode.image?.texture
            self.addChild(n)
            return n
        })
    }
    
    func animateTick() -> Promise<QueuedEventsNode> {
        let action = SKAction.move(by: CGVector.init(dx: -30, dy: 0), duration: 0.1)
        let animationPromises = self.turnBeginsNodes.map { (node) -> Promise<SKNode> in
            return node.runActionPromise(action: action)
        }
        return when(fulfilled: animationPromises).map({ _ in return self  })
    }
    
    func handleEnqueuedEvent(event: EventType, time: Int) {
        
        switch event {
            
        case .turnBegan(let uuid):
            
            var node: TurnBeginsNode? = turnBeginsNodes.first { $0.actorUuid == uuid }
            if node == nil {
                let n = TurnBeginsNode.init(actorUuid: uuid)
                node = n
                self.addChild(n)
                self.turnBeginsNodes.append(n)
            }
            
            node?.position = CGPoint.init(x: time*30, y: 0)
        
        default:
            return
            
        }
        
    }
    
}

class TurnBeginsNode: SKNode {
    
    let actorUuid: UUID
    var spriteNode: SKSpriteNode?
    
    init(actorUuid: UUID) {
        self.actorUuid = actorUuid
        super.init()
        let pictureNode = SKSpriteNode.init(color: UIColor.red, size: CGSize.init(width: 30, height: 30))
        self.addChild(pictureNode)
        self.spriteNode = pictureNode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

//class QueuedEventNode: SKNode {
//
//    override init() {
//
//    }
//}
