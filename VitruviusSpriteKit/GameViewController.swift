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

enum State {
    case waitingForAnimation
    case waitingForPlayerAction
    case draggingCard(CardNode, SKNode)
}

class GameViewController: UIViewController, CardNodeTouchDelegate {

    var handNode: HandNode!
    var playArea: PlayAreaNode!
    
    var state: State = .waitingForAnimation
    var scene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView
    
        
        let scene = SKScene(fileNamed: "BattleScene")
        scene?.scaleMode = .aspectFill
        self.scene = scene!
        
        print("SCENE PARENT IS \(scene!.parent)")
        
        // Present the scene
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        // Add the hand node
        let handNode = HandNode()
        self.handNode = handNode
        scene?.addChild(handNode)
        
        handNode.position = CGPoint(x:0, y: -200)
        
        // Now create and animate some cards
        let a = CardNode.newInstance(delegate: self)
        let b = CardNode.newInstance(delegate: self)
        let c = CardNode.newInstance(delegate: self)
        let d = CardNode.newInstance(delegate: self)
        let e = CardNode.newInstance(delegate: self)
        let f = CardNode.newInstance(delegate: self)

        scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: a), completion: {
            scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: b), completion: {
                scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: c), completion: {
                    scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: d), completion: {
                        scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: e), completion: {
                            scene?.run(handNode.addCardAndAnimationIntoPosiiton(cardNode: f), completion: {
                                // Do nothing
                            })
                        })
                    })
                })
            })
        })
        
        // Let's add some actors
        let playArea = PlayAreaNode()
        scene?.addChild(playArea)
        playArea.position = CGPoint.zero

        playArea.addPlayerAndEnemies(
            player: ActorNode.newInstance(),
            enemies: [ActorNode.newInstance(), ActorNode.newInstance()]
        )
        
        // Save the play area...
        self.playArea = playArea
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
    
    // CardNodeTouchDelegate
    
    func touchesBegan(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
        self.state = .draggingCard(card, card.parent!)
        
        // Move the hand down...
        let a = SKAction.moveTo(y: -400, duration: 0.2)
        self.handNode.run(a)
        card.zPosition = 1
  
        self.scene.addChildPreserveTransform(child: card)
        
        card.run(SKAction.group([
            SKAction.rotate(toAngle: 0, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
    }
    
    func touchesEnded(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
        print(touches.first!.location(in: self.scene).y)
        
        // Check to see if the card has been dragged out enough
        if card.position.y >= -100 {
            
            // Check to see if the card has a single target
            
            if card.requiresSingleTarget() {
                // Go into target selection mode...
                self.playArea.isUserInteractionEnabled = true
                
            } else {
                // Just play the card...
            }
            
        } else {
            
            // Put the card back in the hand
            
            card.zPosition = 0
            
            // Move the hand back up
            let a = SKAction.moveTo(y: -200, duration: 0.2)
            self.handNode.run(a)
            
            switch state {
            case .draggingCard(let card, let parent):
                
                parent.addChildPreserveTransform(child: card)
                
                card.run(SKAction.group([
                    SKAction.move(to: CGPoint.init(x: 0, y: 0), duration: 0.2),
                    SKAction.rotate(toAngle: 0, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ]))
                
            default:
                break
            }
            
        }
    }
    
    func touchesMoved(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        card.position = touches.first!.location(in: card.parent!)
    }
    
    func touchesCancelled(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}


extension SKNode {
    
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
        
        let globalPosition = child.scene!.convert(child.position, from: child.parent!)
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
