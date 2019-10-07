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
        
        let wedge = Double.pi/2.0
        let b = Double(cardsInHand-1)
        let wedgeSize = 60.0
        let c = (Double.pi/(wedgeSize * 2.0))
        var firstPosition = wedge - (b * c)
        
        // Animate each of the nodes in the hand
        for (idx, cardPositionNode) in self.children.enumerated() {
            
            let i = min(cardsInHand, idx)
            
            // We want to use up pi/8 of an arc
            
            // Each part can take up pi/80
            
            let rotation = firstPosition + Double(i) * Double.pi/wedgeSize
            
            let circleRadius = 3000.0
            
            let xPosition = 0 + circleRadius * cos(rotation)
            let yPosition = -circleRadius + circleRadius * sin(rotation)
            let rot = rotation - (Double.pi/2.0)
            
            cardPositionNode.removeAllActions()
            cardPositionNode.run(SKAction.group([
                SKAction.rotate(toAngle: CGFloat(rot), duration: duration),
                SKAction.move(to: CGPoint(x: xPosition, y: yPosition), duration: duration),
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
    
    func setCardsInteraction(enabled: Bool) {
        for c in self.cards {
            c.isUserInteractionEnabled = enabled
        }
    }
    
}
