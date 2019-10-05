//
//  HandNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 4/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class HandNode: SKNode {

    func addCardAndAnimationIntoPosiiton(cardNode: SKNode) -> SKAction {
    
        let child = SKNode()
        
        self.addChild(child)

        child.addChild(cardNode)
        child.setScale(0.8)

        cardNode.alpha = 0.0
        cardNode.position = CGPoint(x: -200, y: 0)
        cardNode.setScale(0.3)

        let duration = 0.2
        
        let cardCount = CGFloat(self.children.count)

        for (i, cardPositionNode) in self.children.enumerated()  {

            print(cardPositionNode)

            cardPositionNode.isPaused = false
            cardPositionNode.zPosition = CGFloat(i)

            let xPosition = -75 * (1 * (cardCount-1.0) + (-2 * CGFloat(i)))
            let rot = 0.05 * (1 * (cardCount-1.0) + (-2 * CGFloat(i)))

            cardPositionNode.run(SKAction.group([
                SKAction.rotate(toAngle: rot, duration: duration),
                SKAction.move(to: CGPoint(x: xPosition, y: 0), duration: duration),
            ]))
            
            cardNode.run(SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: duration),
                SKAction.scale(to: 1.0, duration: duration),
                SKAction.move(to: CGPoint(x: 0, y: 0), duration: duration),
            ]))
            
        }
        
        return SKAction.customAction(withDuration: duration+0.1) { (_, _) in
            // Do nothing
        }
    }
    
    func removeCardAndAnimateIntoPosition(card: SKNode) -> SKAction {
        
        fatalError()
    }
    
}
