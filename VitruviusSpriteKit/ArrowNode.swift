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
    var averagePosition: CGPoint = CGPoint.zero
    var phase: CGFloat = 0
    
    override init() {
        super.init()
        self.shapeNode = SKShapeNode()
        self.addChild(shapeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.shapeNode = SKShapeNode()
        self.addChild(shapeNode)
    }
    
    func updateArrow() {
    }
    
    func updateWithTimeInterval(timeInterval: TimeInterval) {
        
        guard self.isHidden == false else { return }
        
        // Move towards the midpoint of the two points
        guard let tip = self.tipNode,
            let tail = self.tailNode else {
                return
        }
        
        let midPoint = CGPoint(
            x: (tip.position.x + tail.position.x)/2.0,
            y: (tip.position.y + tail.position.y)/2.0
        )
        
        let maxStep = min(10 * timeInterval, 1.0)
        
        let newX = self.averagePosition.x * CGFloat(1 - maxStep) + midPoint.x * CGFloat(maxStep)
        let newY = self.averagePosition.y * CGFloat(1 - maxStep) + midPoint.y * CGFloat(maxStep)
        
        self.averagePosition = CGPoint(x: newX, y: newY)
        
        let bezierPath = UIBezierPath()
        let startPoint = tip.position
        let endPoint = tail.position
                
        bezierPath.move(to: startPoint)
        bezierPath.addCurve(to: endPoint, controlPoint1: self.averagePosition, controlPoint2: self.averagePosition)

        self.phase += CGFloat(timeInterval * 10)
        if self.phase > 20.0 {
            self.phase = self.phase - 20.0
        }
        
        let pattern : [CGFloat] = [10.0, 10.0]
        let dashed = bezierPath.cgPath.copy(dashingWithPhase: self.phase, lengths: pattern)
                
        self.shapeNode.path = dashed
        self.shapeNode.lineWidth = 4.0
        self.shapeNode.strokeColor = UIColor.red
        
    }
    
    
}
