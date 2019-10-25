//
//  BattleViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class BattleViewController: UIViewController {
    
    var battleState: BattleState!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let view: SKView = self.view as! SKView
        
        let scene = SKScene(fileNamed: "BattleScene") as! BattleScene
        scene.scaleMode = .aspectFill
        scene.setBattleState(battleState: battleState)

        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)
    }
}
