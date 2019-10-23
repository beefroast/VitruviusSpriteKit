//
//  TestCardViewerScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 22/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import CollectionNode


protocol IUpdatable {
    func updateNode(currentTime: TimeInterval)
}

extension CollectionNode: IUpdatable {
    func updateNode(currentTime: TimeInterval) {
        self.update(currentTime)
    }
}

class TestCardViewerScene: SKScene, CollectionNodeDataSource, CollectionNodeDelegate {

    private var collectionNode: CollectionNode!
    private var cardNodes: [CardNode]!
    
    let bigScale: CGFloat = 1.0
    let smallScale: CGFloat = 0.8
    
    override func didMove(to view: SKView) {
        
        collectionNode = CollectionNode(at: view)
        
        collectionNode.spaceBetweenItems = 40
        
        let cards = [
            CSStrike().instance(level: 1, uuid: UUID()),
            CSStrike().instance(),
            CSStrike().instance(),
            CSStrike().instance(),
            CSDefend().instance(level: 1, uuid: UUID()),
            CSDefend().instance(),
            CSDefend().instance(),
            CSDefend().instance(),
            CSFireball().instance(),
            CSRecall().instance(),
        ]
        
        cardNodes = cards.map({ (card) -> CardNode in
            let c = CardNode.newInstance()
            c.setupWith(card: card)
            c.size = CGSize(width: 50, height: 50)
            c.xScale = smallScale
            c.yScale = smallScale
            return c
        })
        
        collectionNode.dataSource = self
        collectionNode.delegate = self

        addChild(collectionNode)
        
        self.collectionNode(collectionNode, didShowItemAt: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        collectionNode.update(currentTime)
    }
    
    func numberOfItems() -> Int {
        return cardNodes.count
    }

    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem {
        //create and configure items
        let collectionNodeItem = CollectionNodeItem()
        let cardNode = self.cardNodes[index]
        cardNode.removeFromParent()
        collectionNodeItem.addChild(cardNode)
        return collectionNodeItem
    }
    
    var lastSelectedIndex: Int? = nil
    
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) {
        
        guard index != lastSelectedIndex else { return }

        let nextNode = cardNodes[index]
        nextNode.run(SKAction.scale(to: bigScale, duration: 0.2))
        nextNode.zPosition = 10

        if let last = lastSelectedIndex {
            let last = cardNodes[last]
            last.run(SKAction.scale(to: smallScale, duration: 0.2))
            last.zPosition = 0
        }

        lastSelectedIndex = index
    }

    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index) {
        
        if index == lastSelectedIndex {
            print("Selected: \(index)")
        } else {
            collectionNode.snap(to: index, withDuration: 0.2)
            self.collectionNode(collectionNode, didShowItemAt: index)
        }
    }
    
    
    
}
