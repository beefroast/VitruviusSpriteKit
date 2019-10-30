//
//  BuildingNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol BuildingNodeDelegate: AnyObject {
    func onPressed(sender: BuildingNode)
}

class BuildingNode: SKNode {
    
    weak var delegate: BuildingNodeDelegate? = nil
    var building: Building? = nil
    
    var nameLabel: SKLabelNode? = nil
    var statusLabel: SKLabelNode? = nil
    var statusBarForeground: SKSpriteNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nameLabel = self.getFirstChildRecursive(fn: { (node) -> Bool in node.name == "name" }) as? SKLabelNode
        self.statusBarForeground = self.getFirstChildRecursive(fn: { (node) -> Bool in node.name == "foreground" }) as? SKSpriteNode
        self.statusLabel = self.getFirstChildRecursive(fn: { (node) -> Bool in node.name == "title" }) as? SKLabelNode
    }
    

    static func newInstance(building: Building, delegate: BuildingNodeDelegate?) -> BuildingNode {
        let scene = SKScene(fileNamed: "BuildingNodeScene")
        let node = scene?.children.first
        let buildingNode = node as! BuildingNode
        
        buildingNode.building = building
        building.configureBuildingNode(node: buildingNode)
        
        return buildingNode
    }
}
