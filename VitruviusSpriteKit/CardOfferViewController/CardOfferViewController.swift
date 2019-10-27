//
//  CardOfferViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 27/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol CardOfferViewControllerDelegate: AnyObject {
    func cardOffer(vc: CardOfferViewController, selectedCard: Card?)
}

class CardOfferViewController: UIViewController {

    weak var delegate: CardOfferViewControllerDelegate? = nil
    
    @IBOutlet var skView: SKView? = nil
    
    var cards: [Card] = []
    
    override func viewDidLoad() {
        
    }
    
    
    
}
