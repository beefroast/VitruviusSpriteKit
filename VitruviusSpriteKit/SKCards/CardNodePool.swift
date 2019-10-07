//
//  CardNodePool.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 7/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


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
