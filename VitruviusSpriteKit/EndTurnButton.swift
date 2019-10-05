//
//  EndTurnButton.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 5/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol EndTurnButtonDelegate: AnyObject {
    func endTurnPressed(button: EndTurnButton)
}

class EndTurnButton: SKSpriteNode {
    
    weak var delegate: EndTurnButtonDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.endTurnPressed(button: self)
    }
}
