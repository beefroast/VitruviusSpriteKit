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

    var tipNode: SKNode?
    var tailNode: SKNode?
    var shapeNode: SKShapeNode!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateArrow() {
        
        guard let tip = self.tipNode,
            let tail = self.tailNode else {
                return
        }
        
        let bezierPath = UIBezierPath()
        let startPoint = tip.position
        let endPoint = tail.position
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)

        let pattern : [CGFloat] = [10.0, 10.0]
        let dashed = bezierPath.cgPath.copy(dashingWithPhase: 1, lengths: pattern)
        
        self.shapeNode.path = dashed
        self.shapeNode.lineWidth = 4.0
        self.shapeNode.strokeColor = UIColor.red
        
    }
    
    
    
}
