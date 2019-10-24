//
//  ViewDeckViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 24/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol ViewDeckViewControllerDelegate: AnyObject {
    func viewDeck(viewController: ViewDeckViewController, selectedCard: Card, node: CardNode)
    func viewDeck(viewController: ViewDeckViewController, pressedClose: Any?)
}

class ViewDeckViewController: UIViewController, ViewDeckSceneDelegate {

    weak var delegate: ViewDeckViewControllerDelegate? = nil
    @IBOutlet weak var btnClose: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let view = self.view as! SKView

        let scene = SKScene(fileNamed: "ViewDeckScene") as! ViewDeckScene
        scene.scaleMode = .aspectFill
        
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.allowsTransparency = true
        scene.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
//        self.view.backgroundColor = UIColor.clear
//        self.view.isOpaque = false
        
        let cards: [Card] = [
            CSStrike().instance(level: 1, uuid: UUID()),
            CSStrike().instance(),
            CSStrike().instance(),
            CSStrike().instance(),
            CSDefend().instance(level: 1, uuid: UUID()),
            CSDefend().instance(),
            CSDefend().instance(),
            CSDefend().instance(),
            CSFireball().instance(),
            CSRecall().instance(),
        ]
        
        scene.cards = cards
        scene.viewDeckDelegate = self
        
        view.presentScene(scene)
        
    }
    
    @IBAction func onClosePressed(_ sender: Any) {
        self.delegate?.viewDeck(viewController: self, pressedClose: sender)
    }
    
    // MARK: - ViewDeckSceneDelegate Implementation
    
    func viewDeck(scene: ViewDeckScene, selectedCard: Card, node: CardNode) {
        self.delegate?.viewDeck(viewController: self, selectedCard: selectedCard, node: node)
    }
    
    // MARK: - Static Helper Methods
    
    static func newInstance(delegate: ViewDeckViewControllerDelegate? = nil) -> ViewDeckViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ViewDeckViewController") as! ViewDeckViewController
        vc.delegate = delegate
        return vc
    }

}
