//
//  ChooseRewardNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 17/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import SpriteKit

protocol ChooseRewardNodeDelegate : AnyObject {
    func chooseReward(node: ChooseRewardNode, chose: CardNode)
}

class ChooseRewardNode: SKNode, CardNodeTouchDelegate {

    weak var delegate: ChooseRewardNodeDelegate? = nil

    func setupWith(cards: [Card], cardNodePool: CardNodePool) -> Void {
        
        let cardNodes = cards.map { (c) -> CardNode in
            let node = cardNodePool.getFromPool()
            self.addChildPreserveTransform(child: node)
            node.resetTransforms()
            return node.setupWith(card: c)
        }
        
        // Evenly space the card nodes
        let width = 600.0
        
        cardNodes.enumerated().forEach { (pair) in
            let cardNode = pair.element
            let offset = Double(pair.offset)
            let space = width/Double(cardNodes.count-1)
            let xPos = -width*0.5 + space*offset
            cardNode.delegate = self
            cardNode.position = CGPoint.init(x: xPos, y: 0)
            cardNode.isUserInteractionEnabled = true
        }
        
        let background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), size: CGSize(width: 2000, height: 1000))
        background.zPosition = -1
        self.addChild(background)
        
        let title = SKLabelNode(text: "Choose a reward.")
        title.color = UIColor.white
        self.addChild(title)
        title.position = CGPoint.init(x: 0, y: 200)

    }
    
    // MARK: - CardNodeTouchDelegate Implementation
    
    func touchesBegan(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.chooseReward(node: self, chose: card)
    }
    
    func touchesEnded(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func touchesMoved(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func touchesCancelled(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}
