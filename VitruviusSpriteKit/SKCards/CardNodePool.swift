//
//  CardNodePool.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 7/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import SpriteKit


class CardNodePool {
    
    var cardNode: [CardNode]
    
    init() {
        self.cardNode = (0...20).map({ (i) -> CardNode in
            CardNode.newInstance()
        })
    }
    
    func getFromPool() -> CardNode {
        return self.cardNode.removeFirst()
    }
    
    func returnToPool(cardNode: CardNode) {
        self.cardNode.append(cardNode)
        cardNode.removeFromParent()
    }
    
    
}

extension SKNode {
    func resetTransforms() {
        self.zPosition = 0
        self.xScale = 1
        self.yScale = 1
        self.zRotation = 0
        self.alpha = 1
    }
}
