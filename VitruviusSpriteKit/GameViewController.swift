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
        
  
//        let scene = getBattleScene()
        let scene = SKScene(fileNamed: "TownScene") as! TownScene
        scene.scaleMode = .aspectFit
        
        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)



        
    }
    
    func getBattleScene() -> SKScene {
             
       let player = Player(
           uuid: UUID(),
           name: "Player",
           faction: .player,
           body: Body(block: 0, hp: 72, maxHp: 72),
           cardZones: CardZones(
               hand: Hand.newEmpty(),
               drawPile: DrawPile.init(cards: [
                   CSStrike().instance(level: 1),
                   CSStrike().instance(),
                   CSStrike().instance(),
                   CSStrike().instance(),
                   CSDefend().instance(),
                   CSDefend().instance(),
                   CSDefend().instance(),
                   CSDefend().instance(),
                   CSFireball().instance(),
                   CSRecall().instance(),
                   CSMasteryPotion().instance()
               ]),
               discard: DiscardPile()
           ),
           currentMana: 3,
           maxMana: 3
       )
       
       
       
       
       let goomba = Enemy(
            uuid: UUID(),
            name: "Goomba",
            faction: .enemies,
            body: Body(block: 0, hp: 40, maxHp: 40),
            cardZones: CardZones(
               hand: Hand.newEmpty(),
               drawPile: DrawPile.newEmpty(),
                discard: DiscardPile()
            ),
            enemyStrategy: CrabEnemyStrategy()
        )
        
        
        let koopa = Enemy(
            uuid: UUID(),
            name: "Koopa",
            faction: .enemies,
            body: Body(block: 0, hp: 40, maxHp: 40),
            cardZones: CardZones(
               hand: Hand.newEmpty(),
               drawPile: DrawPile.init(cards: [
                   CSStrike().instance(),
                   CSDefend().instance()
               ]),
                discard: DiscardPile()
            ),
            enemyStrategy: SuccubusEnemyStrategy()
        )
       
       let battleState = BattleState.init(
           player: player,
           allies: [],
           enemies: [goomba, koopa],
           eventHandler: EventHandler(
               uuid: UUID(),
               eventStack: StackQueuePrinter<Event>(),
               effectList: [
                   EventPrinterEffect.init().withWrapper(uuid: UUID())
               ]
           ),
           rng: SeededRandomNumberGenerator(count: 0, seed: 0)
       )
               
       
       battleState.eventHandler.push(events: [
           Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: player.uuid, cardsDrawn: 5).withWrapper(uuid: UUID())),
           Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: goomba.uuid, cardsDrawn: 0).withWrapper(uuid: UUID())),
           Event.addEffect(DiscardThenDrawAtEndOfTurnEffect(ownerUuid: koopa.uuid, cardsDrawn: 1).withWrapper(uuid: UUID()))
       ])


       // Load the battle scene
       let scene = SKScene(fileNamed: "BattleScene") as! BattleScene
       scene.scaleMode = .aspectFit
       scene.setBattleState(battleState: battleState)
        
        return scene
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
    
    func getFirstChildRecursive(fn: (SKNode) -> Bool) -> SKNode? {
        
        if fn(self) {
            return self
        
        } else {
            for c in self.children {
                if let found =  c.getFirstChildRecursive(fn: fn) {
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
    
    func getGlobalZPosition() -> CGFloat {
        return self.zPosition + (self.parent?.getGlobalZPosition() ?? 0.0)
    }
    
    func setGlobalZPosition(z: CGFloat) -> Void {
        self.zPosition = z - (self.parent?.getGlobalZPosition() ?? 0.0)
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
        let globalZ = child.getGlobalZPosition()
        
        child.removeFromParent()
        self.addChild(child)
        
        // TODO: Position
        
        child.position = child.scene!.convert(globalPosition, to: self)
        child.setGlobalRotation(z: globalRotation)
        child.setGlobalXScale(x: globalXScale)
        child.setGlobalYScale(y: globalYScale)
        child.setGlobalZPosition(z: globalZ)
    }

    
}
