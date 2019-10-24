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

    var onSelectedCard: ((ViewDeckViewController, Card) -> Void)?
    var onPressedClose: ((ViewDeckViewController) -> Void)?
    
    weak var delegate: ViewDeckViewControllerDelegate? = nil
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubtitle: UILabel?
    
    // Dummy card here because CollectionNode crashes if there's
    // nothing to display
    var cards: [Card] = [CSStrike().instance()] {
        didSet {
            self.viewDeckScene?.cards = cards
        }
    }
    
    private var viewDeckScene: ViewDeckScene? = nil
    
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
        
        scene.cards = self.cards
        scene.viewDeckDelegate = self
        
        view.presentScene(scene)
        self.viewDeckScene = scene
        
    }
    
    @IBAction func onClosePressed(_ sender: Any) {
        self.delegate?.viewDeck(viewController: self, pressedClose: sender)
        self.onPressedClose?(self)
    }
    
    // MARK: - ViewDeckSceneDelegate Implementation
    
    func viewDeck(scene: ViewDeckScene, selectedCard: Card, node: CardNode) {
        self.delegate?.viewDeck(viewController: self, selectedCard: selectedCard, node: node)
        self.onSelectedCard?(self, selectedCard)
    }
    
    // MARK: - Static Helper Methods
    
    static func newInstance(delegate: ViewDeckViewControllerDelegate? = nil) -> ViewDeckViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ViewDeckViewController") as! ViewDeckViewController
        vc.delegate = delegate
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    static var sharedInstance: ViewDeckViewController = {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ViewDeckViewController") as! ViewDeckViewController
        let v = vc.view
        return vc
    }()
    
    static func newInstance(
        titleText: String,
        subtitleText: String,
        cards: [Card],
        onSelectedCard: @escaping (ViewDeckViewController, Card) -> Void,
        onPressedClose: @escaping (ViewDeckViewController) -> Void) -> ViewDeckViewController {
        
        let vc = sharedInstance
        vc.cards = cards
        vc.lblTitle?.text = titleText
        vc.lblSubtitle?.text = subtitleText
        vc.onSelectedCard = onSelectedCard
        vc.onPressedClose = onPressedClose
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }

}
