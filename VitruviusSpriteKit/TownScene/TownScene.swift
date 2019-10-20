//
//  TownScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 20/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit



class TownScene: SKScene {

    
    
}

protocol BuildingNodeDelegate: AnyObject {
    
}

class BuildingNode: SKNode {
    

    
    
}

protocol HomeOverlayNodeDelegate: AnyObject {
    func homeOverlayNodeChoseRest(sender: HomeOverlayNode)
    func homeOverlayNodeCancelled(sender: HomeOverlayNode)
}

class HomeOverlayNode: SKNode {
    
    weak var delegate: HomeOverlayNodeDelegate? = nil
    
    
}


// Message board
// Home

class Building {
    let name: String
    
}

