//
//  TownViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 24/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class TownViewController: UIViewController {

    var playerData: PlayerData!
    
    @IBOutlet weak var lblHp: UILabel!
    @IBOutlet weak var lblGp: UILabel!
    @IBOutlet weak var lblCards: UILabel!
    @IBOutlet weak var lblDaysRemaining: UILabel!
    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerData = PlayerData.newPlayerFor(name: "Benji", characterClass: .wizard)
        
        self.lblCards.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(onCardsTapped(sender:))))
        self.lblCards.isUserInteractionEnabled = true
        
        self.setupWith(data: self.playerData)
        
        let scene = SKScene(fileNamed: "TownScene") as! TownScene
        scene.scaleMode = .aspectFill
//        scene.townSceneDelegate = self
                
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
        self.lblDaysRemaining.text = "\(data.daysUntilNextBoss) until \(data.nextBoss) arrives."
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
