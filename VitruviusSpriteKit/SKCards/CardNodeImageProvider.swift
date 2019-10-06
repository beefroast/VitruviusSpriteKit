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
            
        default:
            return SKTexture(imageNamed: "placeholder")
            
            
        }
        
    }
    
}
