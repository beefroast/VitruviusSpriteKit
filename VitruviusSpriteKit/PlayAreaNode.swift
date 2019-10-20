//
//  PlayAreaNode.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 5/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class PlayAreaNode: SKNode {
    

    func addPlayerAndEnemies(player: ActorNode, enemies: [ActorNode]) {

        let totalCount = 1 + enemies.count
        let totalWidth: CGFloat = 600.0
        let spaceBetween = totalWidth/CGFloat(totalCount)
        let left = -totalWidth/2.0

        // Space them
        for i in (0...totalCount) {
            
            let node = SKNode()
            self.addChild(node)
            node.position = CGPoint(x: left + CGFloat(i) * spaceBetween, y: 0)
            
            if i == 0 {
                node.addChild(player)
                player.position = CGPoint.zero
                
            } else if i > 1 {
                node.addChild(enemies[i-2])
                enemies[i-2].position = CGPoint.zero
                
            }
            
        }
    }
    
    func actorNode(withUuid uuid: UUID) -> ActorNode? {
        return self.getFirstChildRecursive { (node) -> Bool in
            (node as? ActorNode)?.actorUuid == uuid
        } as? ActorNode
    }

    
    
    
}
