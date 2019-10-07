//
//  FontHandler.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 6/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import UIKit

/// For attributed strings
class FontHandler {
    
    
    func getDamageText(amount: Int) -> NSAttributedString {
        
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeWidth: -3.0,
            .strokeColor: UIColor.white,
            .foregroundColor: UIColor.red,
            .font: UIFont(name: "Avenir-Black", size: 36)
        ]

        return NSAttributedString(string: "\(amount)", attributes: attributes)
        
    }
    
    func getCardTitle(title: String) -> NSAttributedString {
        
        
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeWidth: -6.0,
             .strokeColor: UIColor.black,
             .foregroundColor: UIColor.white,
             .font: UIFont(name: "Avenir-Black", size: 48)
         ]

         return NSAttributedString(string: "\(title)", attributes: attributes)
    }
    
    func getCardText(text: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
             .foregroundColor: UIColor.white,
             .font: UIFont(name: "Avenir", size: 36),
         ]

        return NSAttributedString(string: "\(text)", attributes: attributes)


        
    }

}
