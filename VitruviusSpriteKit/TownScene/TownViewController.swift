//
//  TownViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 24/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class TownViewController: UIViewController, TavernViewControllerDelegate {

    var gameState: GameState!
    var townScene: TownScene!
    
    @IBOutlet weak var lblHp: UILabel!
    @IBOutlet weak var lblGp: UILabel!
    @IBOutlet weak var lblCards: UILabel!
    @IBOutlet weak var lblDaysRemaining: UILabel!
    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        self.lblCards.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onCardsTapped(sender:))))
        self.lblCards.isUserInteractionEnabled = true
        
        self.setupWith(data: self.gameState.playerData)
        
        let scene = SKScene(fileNamed: "TownScene") as! TownScene
        scene.scaleMode = .aspectFill
        scene.viewController = self
        scene.setGameState(gameState: gameState)
        self.townScene = scene
                
        // Present the scene
        skView.ignoresSiblingOrder = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.presentScene(scene)
        
    }
    
    func setupWith(data: PlayerData) {
        self.lblHp.text = "\(data.currentHp)/\(data.maxHp)hp"
        self.lblGp.text = "\(data.currentGold)gp"
        self.lblCards.text = "\(data.decklist.count)"
        self.lblDaysRemaining.text = "\(data.daysUntilNextBoss) days until \(data.nextBoss) arrives."
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TavernViewController {
            vc.delegate = self
            
        } else if let vc = segue.destination as? BattleViewController {
            vc.battleState = sender as! BattleState
        }
    }
    
    // MARK: - TavernViewControllerDelegate Implementation
    
    func tavern(viewController: TavernViewController, selectedMission: Mission) {
        let battleState = selectedMission.getBattleState(gameState: self.townScene.gameState)
        let vc = BattleViewController.newInstance(battleState: battleState)
        self.navigationController?.setViewControllers([vc], animated: false)
    }
    
    func tavern(viewController: TavernViewController, selectedRest: Any?) {
        self.navigationController?.popViewController(animated: true)
        
        self.gameState.playerData.currentHp = min(self.gameState.playerData.currentHp + 20, self.gameState.playerData.maxHp)
        self.gameState.playerData.daysUntilNextBoss = self.gameState.playerData.daysUntilNextBoss - 1
        self.setupWith(data: self.gameState.playerData)
        
        self.townScene.tavern(viewController: viewController, selectedRest: selectedRest)
    }
    
    func tavern(viewController: TavernViewController, cancelled: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Actions
    
    @objc func onCardsTapped(sender: Any?) {
        
        let vc = ViewDeckViewController.newInstance(
            titleText: "Your deck",
            subtitleText: "You can upgrade your deck in buildings or on adventures.",
            cards: self.gameState.playerData.decklist,
            onSelectedCard: { (vc, card) in
                print("Selected \(card.name).")
                vc.dismiss(animated: true, completion: nil)
            },
            onPressedClose: { (vc) in
                vc.dismiss(animated: true, completion: nil)
            })
        
        self.present(vc, animated: true, completion: nil)
    }
    

}
