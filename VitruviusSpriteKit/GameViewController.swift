//
//  GameViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 3/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


// TODO: Move this into a scene

class GameViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView
        
        
        // Make a test battle state
        
        let player = Actor(
            uuid: UUID(),
            name: "Player",
            faction: .player,
            body: Body(block: 0, hp: 72, maxHp: 72),
            cardZones: CardZones(
                hand: Hand.init(),
                drawPile: DrawPile.init(cards: [
                    CardStrike(),
                    CardStrike(),
                    CardStrike(),
                    CardStrike(),
                    CardDefend(),
                    CardDefend(),
                    CardDefend(),
                    CardDefend(),
                    CardFireball(),
                    CardRecall(),
                    
                ]),
                discard: DiscardPile()
        ))
        
        let goomba = TestEnemy(
             uuid: UUID(),
             name: "Goomba",
             faction: .enemies,
             body: Body(block: 0, hp: 40, maxHp: 40),
             cardZones: CardZones(
                 hand: Hand(),
                 drawPile: DrawPile(cards: []),
                 discard: DiscardPile()
             ),
             preBattleCards: []
         )
         
         
         let koopa = TestEnemy(
             uuid: UUID(),
             name: "Koopa",
             faction: .enemies,
             body: Body(block: 0, hp: 40, maxHp: 40),
             cardZones: CardZones(
                 hand: Hand(),
                 drawPile: DrawPile(cards: []),
                 discard: DiscardPile()
             ),
             preBattleCards: []
         )
        
        let battleState = BattleState.init(
            player: player,
            allies: [],
            enemies: [goomba, koopa],
            eventHandler: EventHandler(
                eventStack: StackQueue<Event>(),
                effectList: [
                    EventPrinterEffect(uuid: UUID(), name: "Printer")
                ]
            )
        )
                
        battleState.eventHandler.push(event:
            Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(
                uuid: UUID(),
                ownerUuid: player.uuid,
                name: "Player discard then draw.",
                cardsDrawn: 5
            ))
        )

 
        // Load the battle scene
        let scene = SKScene(fileNamed: "BattleScene") as! BattleScene
        scene.scaleMode = .aspectFit
        scene.setBattleState(battleState: battleState)
        
        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)

        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    


}


extension SKNode {
    
    func getFirstRecursive(fn: (SKNode) -> Bool) -> SKNode? {
        
        if fn(self) {
            return self
        
        } else {
            for c in self.children {
                if let found =  c.getFirstRecursive(fn: fn) {
                    return found
                }
            }
            return nil
        }
    }

    
    func getGlobalPosition() -> CGPoint {
        guard let parent = self.parent, let scene = self.scene else {
            return CGPoint.zero
        }
        return scene.convert(self.position, from: parent)
    }
    
    func getGlobalRotation() -> CGFloat {
        return self.zRotation + (self.parent?.getGlobalRotation() ?? 0.0)
    }
    
    func setGlobalRotation(z: CGFloat) {
        self.zRotation = z - (self.parent?.getGlobalRotation() ?? 0.0)
    }
    
    func getGlobalXScale() -> CGFloat {
        return self.xScale * (self.parent?.getGlobalXScale() ?? 1.0)
    }
    
    func setGlobalXScale(x: CGFloat) -> Void {
        self.xScale = x / (self.parent?.getGlobalXScale() ?? 1.0)
    }
    
    func getGlobalYScale() -> CGFloat {
        return self.yScale * (self.parent?.getGlobalYScale() ?? 1.0)
    }
    
    func setGlobalYScale(y: CGFloat) -> Void {
        self.yScale = y / (self.parent?.getGlobalYScale() ?? 1.0)
    }
    
    
    func addChildPreserveTransform(child: SKNode) -> Void {
        
        if child.parent === self {
            return
        }
        
        guard let parent = child.parent else {
            self.addChild(child)
            return
        }
        
        let globalPosition = child.scene!.convert(child.position, from: parent)
        let globalRotation = child.getGlobalRotation()
        let globalXScale = child.getGlobalXScale()
        let globalYScale = child.getGlobalYScale()
        
        child.removeFromParent()
        self.addChild(child)
        
        // TODO: Position
        
        child.position = child.scene!.convert(globalPosition, to: self)
        child.setGlobalRotation(z: globalRotation)
        child.setGlobalXScale(x: globalXScale)
        child.setGlobalYScale(y: globalYScale)
    }

    
}
