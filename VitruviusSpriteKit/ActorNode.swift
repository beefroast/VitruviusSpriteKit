//
//  ActorNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 5/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class ActorNode: SKNode {

    var actorUuid: UUID? = nil
    var details: SKLabelNode? = nil
    var image: SKSpriteNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = false
        self.details = self.childNode(withName: "details") as? SKLabelNode
        self.image = self.childNode(withName: "image") as? SKSpriteNode
    }
    
    class func newInstance(actor: Actor) -> ActorNode {
        let scene = SKScene(fileNamed: "ActorScene")!
        let node = scene.childNode(withName: "root") as! ActorNode
        node.removeFromParent()
        node.actorUuid = actor.uuid
        node.details?.text = "\(actor.name)\n\(actor.body.description)"
        return node
    }
    
}
