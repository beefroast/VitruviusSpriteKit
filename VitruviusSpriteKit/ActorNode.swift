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
    var healthBar: SKSpriteNode? = nil
    var healthBarText: SKLabelNode? = nil
    var blockNode: SKSpriteNode? = nil
    var blockAmount: SKLabelNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = false
        self.details = self.childNode(withName: "details") as? SKLabelNode
        self.image = self.childNode(withName: "image") as? SKSpriteNode
        self.healthBar = self.childNode(withName: "healthBar") as? SKSpriteNode
        self.healthBarText = self.healthBar?.childNode(withName: "healthBarText") as? SKLabelNode
        self.blockNode = self.childNode(withName: "blockNode") as? SKSpriteNode
        self.blockAmount = self.blockNode?.childNode(withName: "blockAmount") as? SKLabelNode
        self.blockNode?.isHidden = true
    }
    
    class func newInstance(actor: Actor) -> ActorNode {
        let scene = SKScene(fileNamed: "ActorScene")!
        let node = scene.childNode(withName: "root") as! ActorNode
        node.removeFromParent()
        node.actorUuid = actor.uuid
        node.details?.text = "\(actor.name)"
        
        return node
    }
    
    func setBlock(amount: Int) -> Void {
        if amount == 0 {
            self.blockNode?.isHidden = true
        } else {
            self.blockNode?.isHidden = false
            self.blockAmount?.text = "\(amount)"
        }
    }
    
}
