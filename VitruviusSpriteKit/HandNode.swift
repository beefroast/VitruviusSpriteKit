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
        
    var cardsInHand: Int {
        get { return cards.count }
    }
    
    var cards: [CardNode] = []
    
    func setupNodes() {
        // Add 10 children
        for i in (0...9) {
            let node = SKNode.init()
            node.name = "\(i)"
            self.addChild(node)
            node.position = CGPoint.zero
            node.setScale(0.8)
        }
    }
    
    func animateNodePositions(duration: TimeInterval = 0.2) -> Void {
        
        // Animate each of the nodes in the hand
        for (idx, cardPositionNode) in self.children.enumerated() {
            
            let i = min(cardsInHand, idx)
            let xPosition = -75 * (1 * (CGFloat(cardsInHand)-1.0) + (-2 * CGFloat(i)))
            let rot = 0.05 * (1 * (CGFloat(cardsInHand)-1.0) + (-2 * CGFloat(i)))

            cardPositionNode.removeAllActions()
            cardPositionNode.run(SKAction.group([
                SKAction.rotate(toAngle: rot, duration: duration),
                SKAction.move(to: CGPoint(x: xPosition, y: 0), duration: duration),
            ]))
            
            if idx < self.cards.count {
                
                let cardNode = self.cards[idx]
                
                cardPositionNode.addChildPreserveTransform(child: cardNode)
                
                cardNode.run(SKAction.group([
                    SKAction.move(to: CGPoint.zero, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2),
                    SKAction.rotate(toAngle: 0.0, duration: 0.2),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                ]))
            }
        }
    }
    
    func addCardAndAnimationIntoPosiiton(cardNode: CardNode) -> SKAction {
    
        
        // TODO: Need to re-use our pool of hand positions...
        guard cardsInHand < 10 else {
            fatalError("TODO: Handle too many cards in hand")
        }
        
        self.cards.append(cardNode)
                
        // Animate the card into the position of the node
        self.animateNodePositions()

        return SKAction.customAction(withDuration: 0.02+0.05) { (_, _) in
            // Do nothing
        }
    }
    
    func removeCardAndAnimateIntoPosition(cardNode: CardNode) -> Void {
        
        // Get the parent
        guard let card = self.cards.first(where: { (node) -> Bool in
            node.card.uuid == cardNode.card.uuid
        }) else {
            return
        }
        
        self.cards.removeAll { (node) -> Bool in
            node.card.uuid == cardNode.card.uuid
        }
                
        card.scene?.addChildPreserveTransform(child: card)
        
        self.animateNodePositions()
    }
    
}
