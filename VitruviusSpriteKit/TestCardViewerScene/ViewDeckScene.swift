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

protocol ViewDeckSceneDelegate: AnyObject {
    func viewDeck(scene: ViewDeckScene, selectedCard: Card, node: CardNode)
}



class ViewDeckScene: SKScene, CollectionNodeDataSource, CollectionNodeDelegate {

    weak var viewDeckDelegate: ViewDeckSceneDelegate? = nil
    
    private var collectionNode: CollectionNode?
    
    var cards: [Card] = [] {
        didSet {
            self.cardNodes = cards.map({ (card) -> CardNode in
                let c = CardNode.newInstance()
                c.setupWith(card: card)
                c.size = CGSize(width: 50, height: 50)
                c.xScale = smallScale
                c.yScale = smallScale
                return c
            })
        }
    }
    
    private var cardNodes: [CardNode] = [] {
        didSet {
            guard let collectionNode = self.collectionNode else { return }
            collectionNode.reloadData()
            self.collectionNode(collectionNode, didShowItemAt: 0)
        }
    }
    
    let bigScale: CGFloat = 1.0
    let smallScale: CGFloat = 0.8
    
    override func didMove(to view: SKView) {
        
        view.allowsTransparency = true
        
        let node = CollectionNode(at: view)
        collectionNode = node
        collectionNode?.spaceBetweenItems = 40
        collectionNode?.dataSource = self
        collectionNode?.delegate = self

        addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        collectionNode?.update(currentTime, dampingRatio: 0.001)
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
            self.viewDeckDelegate?.viewDeck(
                scene: self,
                selectedCard: cards[index],
                node: cardNodes[index]
            )
        } else {
            collectionNode.snap(to: index, withDuration: 0.2)
            self.collectionNode(collectionNode, didShowItemAt: index)
        }
    }
    
    
    
}
