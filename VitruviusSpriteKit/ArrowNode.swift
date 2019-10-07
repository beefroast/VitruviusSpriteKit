//
//  ArrowNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 7/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class ArrowNode: SKNode {

    var tipNode: SKNode!
    var tailNode: SKNode!
    var shapeNode: SKShapeNode!
    
    override init() {
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addTipAndTail() {
        self.tipNode = SKNode()
        self.tailNode = SKNode()
        self.shapeNode = SKShapeNode(rectOf: CGSize.zero)
        self.addChild(tipNode)
        self.addChild(tailNode)
    }
    
    func updateArrow() {
        
        let bezierPath = UIBezierPath()
        let startPoint = tipNode.position
        let endPoint = tailNode.position
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)

        var pattern : [CGFloat] = [10.0, 10.0]
        let dashed = bezierPath.cgPath.copy(dashingWithPhase: 1, lengths: pattern)
        
        self.shapeNode.path = dashed
    }
    
    
    
}
