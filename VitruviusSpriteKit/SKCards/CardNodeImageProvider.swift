//
//  CardNodeImageProvider.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 6/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import SpriteKit

class CardNodeImageProvider {
    
    func textureFor(card: ICard) -> SKTexture {
        
        switch card.cardNumber {
            
        case 1:
            return SKTexture(imageNamed: "crab")
            
        case 5:
            return SKTexture(imageNamed: "archery_yard")
            
        case 7:
            return SKTexture(imageNamed: "fireball")
            
        case 6:
            return SKTexture(imageNamed: "mana_storm")
            
        default:
            return SKTexture(imageNamed: "placeholder")
            
            
        }
        
    }
    
}
