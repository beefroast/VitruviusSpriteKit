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

    var playerData: PlayerData!
    var townScene: TownScene!
    
    @IBOutlet weak var lblHp: UILabel!
    @IBOutlet weak var lblGp: UILabel!
    @IBOutlet weak var lblCards: UILabel!
    @IBOutlet weak var lblDaysRemaining: UILabel!
    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let r = RandomnessSource.init(seed: "GEVDNHLZPHYGWNLWALKD")
        let x = try! JSONEncoder().encode(r)
        let s = String.init(data: x, encoding: .utf8)
        print(s!)
        
        
        
        self.playerData = PlayerData.newPlayerFor(name: "Benji", characterClass: .wizard)
        
        self.lblCards.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onCardsTapped(sender:))))
        self.lblCards.isUserInteractionEnabled = true
        
        self.setupWith(data: self.playerData)
        
        let scene = SKScene(fileNamed: "TownScene") as! TownScene
        scene.scaleMode = .aspectFill
        scene.viewController = self
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
        
        self.dismiss(animated: true) {
            let battleState = selectedMission.getBattleState(gameState: self.townScene.gameState)
            self.performSegue(withIdentifier: "battle", sender: battleState)
        }
    }
    
    func tavern(viewController: TavernViewController, selectedRest: Any?) {
        self.dismiss(animated: true, completion: nil)
        
        self.playerData.currentHp = min(self.playerData.currentHp + 20, self.playerData.maxHp)
        self.playerData.daysUntilNextBoss = self.playerData.daysUntilNextBoss - 1
        self.setupWith(data: self.playerData)
        
        self.townScene.tavern(viewController: viewController, selectedRest: selectedRest)
    }
    
    func tavern(viewController: TavernViewController, cancelled: Any?) {
        self.dismiss(animated: true, completion: nil)
        self.townScene.tavern(viewController: viewController, cancelled: cancelled)
    }
    
    // MARK: - Actions
    
    @objc func onCardsTapped(sender: Any?) {
        
        let vc = ViewDeckViewController.newInstance(
            titleText: "Your deck",
            subtitleText: "You can upgrade your deck in buildings or on adventures.",
            cards: self.playerData.decklist,
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
