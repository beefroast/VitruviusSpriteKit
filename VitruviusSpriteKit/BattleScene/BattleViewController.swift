//
//  BattleViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class BattleViewController: UIViewController, BattleSceneDelegate {

    var gameState: GameState!
    var battleState: BattleState!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let view: SKView = self.view as! SKView
        
        let scene = SKScene(fileNamed: "BattleScene") as! BattleScene
        scene.scaleMode = .aspectFill
        scene.setBattleState(battleState: self.gameState.currentBattle!)
        scene.battleSceneDelegate = self
        
        
        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)
    }
    
    static func newInstance(gameState: GameState) -> BattleViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "battle") as! BattleViewController
        vc.gameState = gameState
        return vc
        
    }
    
    // MARK: - BattleSceneDelegate Implementation
    
    func onBattleWon(sender: BattleScene) {
        
        // TODO: Continue the mission
        // for now we just go back to the town
        
        self.gameState.currentBattle = nil
        let vc = TownViewController.newInstance(gameState: self.gameState)
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    func onBattleLost(sender: BattleScene) {
        // TODO: Show game over screen.
    }
}
