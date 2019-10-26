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

class BuildingNode: SKSpriteNode {
    
    weak var delegate: BuildingNodeDelegate? = nil
    var building: Building? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.onPressed(sender: self)
    }
    
    static func newInstance(building: Building, delegate: BuildingNodeDelegate?) -> BuildingNode {
        // TODO: Make this so it creates everything we need to display a building
        let node = BuildingNode(imageNamed: "Highlander's_hut")
        node.size = CGSize(width: 100, height: 100)
        node.delegate = delegate
        node.building = building
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = building.descriptiveName()
        label.fontSize = 14
        node.addChild(label)
        
        return node
    }
}
