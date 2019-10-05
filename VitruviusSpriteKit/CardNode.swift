//
//  CardNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 3/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol CardNodeTouchDelegate: AnyObject {
    func touchesBegan(card: CardNode, touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(card: CardNode, touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(card: CardNode, touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(card: CardNode, touches: Set<UITouch>, with event: UIEvent?)
}

class CardNode: SKSpriteNode {
    
    weak var delegate: CardNodeTouchDelegate? = nil
    var card: ICard!
    
    var title: SKLabelNode? = nil
    var cost: SKLabelNode? = nil
    var text: SKLabelNode? = nil
    var image: SKSpriteNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.isPaused = false
        self.title = self.childNode(withName: "title") as? SKLabelNode
        self.cost = self.childNode(withName: "cost") as? SKLabelNode
        self.text = self.childNode(withName: "text") as? SKLabelNode
        self.image = self.childNode(withName: "image") as? SKSpriteNode
    }
    
    class func newInstance(card: ICard, delegate: CardNodeTouchDelegate? = nil) -> CardNode {
        let scene = SKScene(fileNamed: "CardSceneWood")!
        let node = scene.childNode(withName: "root") as! CardNode
        node.card = card
        node.title?.text = card.name
        node.removeFromParent()
        node.delegate = delegate
        return node
    }

    // MARK: - Card Data
    
    func requiresSingleTarget() -> Bool {
        return self.card.requiresSingleTarget
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.delegate?.touchesBegan(card: self, touches: touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.touchesEnded(card: self, touches: touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.touchesMoved(card: self, touches: touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesCancelled on \(title?.name)")
//        self.delegate?.touchesCancelled(card: self, touches: touches, with: event)
    }
    
}
