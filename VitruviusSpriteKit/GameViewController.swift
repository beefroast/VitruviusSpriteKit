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
        
        
        // Get some random rarities
//        case basic
//        case common
//        case uncommon
//        case rare
//        case mythic
        
//        var rarityToCount: [CardRarity: Int] = [
//            .mythic: 0,
//            .rare: 0,
//            .uncommon: 0,
//            .common: 0
//        ]
//
//        let off = CardOfferer()
//        let rng = RandomNumberGenerator()
//        for i in (1...100) {
//            let r = off.getRarityAndAdjustWeights(challengeRating: i, rng: rng)
//            print(r)
//            rarityToCount[r]! += 1
//        }
//
//        print(rarityToCount)
        
        
        let player = Player(
            uuid: UUID(),
            name: "Player",
            faction: .player,
            body: Body(block: 0, hp: 72, maxHp: 72),
            cardZones: CardZones(
                hand: Hand.newEmpty(),
                drawPile: DrawPile.init(cards: [
                    CardStrike().instance(level: 1),
                    CardStrike().instance(),
                    CardStrike().instance(),
                    CardStrike().instance(),
                    CardDefend().instance(),
                    CardDefend().instance(),
                    CardDefend().instance(),
                    CardDefend().instance(),
                    CardFireball().instance(),
                    CardRecall().instance(),
                    CardMasteryPotion().instance()
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
                 drawPile: DrawPile.newEmpty(),
                 discard: DiscardPile()
             ),
             enemyStrategy: CrabEnemyStrategy()
         )
        
        let battleState = BattleState.init(
            player: player,
            allies: [],
            enemies: [goomba, koopa],
            eventHandler: EventHandler(
                uuid: UUID(),
                eventStack: StackQueue<Event>(),
                effectList: [
                    EventPrinterEffect.init().withWrapper(uuid: UUID())
                ]
            ),
            rng: RandomNumberGenerator(count: 0, seed: 0)
        )
                
        battleState.eventHandler.push(event:
            Event.addEffect(
                DiscardThenDrawAtEndOfTurnEffect(
                    ownerUuid: player.uuid, cardsDrawn: 5
                ).withWrapper(uuid: UUID())
            )
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
