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

class GameViewController: UIViewController, CardNodeTouchDelegate, IEffect {
 
    

    var handNode: HandNode!
    var playArea: PlayAreaNode!
    var battleState: BattleState!
    
    var state: State = .waitingForAnimation
    var scene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view as! SKView
    
        
        let scene = SKScene(fileNamed: "BattleScene")
        scene?.scaleMode = .aspectFill
        self.scene = scene!
        
        print("SCENE PARENT IS \(String(describing: scene!.parent))")
        
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
        
        // Get that battle state happening
        
        let player = Actor(
            uuid: UUID(),
            name: "Player",
            faction: .player,
            body: Body(block: 0, hp: 72, maxHp: 72),
            cardZones: CardZones(
                hand: Hand.init(),
                drawPile: DrawPile.init(cards: [
                    CardDefend(),
                    CardDefend(),
                    CardDefend(),
                    CardDefend(),
                    CardDefend(),
                ]),
                discard: DiscardPile()
        ))
        
        let goomba = Enemy(
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
         
         
         let koopa = Enemy(
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
        
        self.battleState = BattleState.init(
            player: player,
            allies: [],
            enemies: [goomba, koopa],
            eventHandler: EventHandler(
                eventStack: StackQueue<Event>(),
                effectList: [EventPrinterEffect(uuid: UUID(), name: "Printer"), self]
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
        
        battleState.eventHandler.push(event: Event.onBattleBegan)
        battleState.eventHandler.popAndHandle(battleState: battleState)
        


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
                self.battleState.eventHandler.push(
                    event: Event.playCard(CardEvent.init(cardOwner: self.battleState.player, card: card.card))
                )
                self.battleState.eventHandler.popAndHandle(battleState: self.battleState)
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
    
    
    // IEffect handler
    
    var uuid: UUID = UUID()
    var name: String = "Game UI"
     
    func handle(event: Event, state: BattleState) -> Bool {
        
        DispatchQueue.main.async {
            
            switch event {
                
            case .onCardDrawn(let e):
                
                // Make the card
                let cardNode = CardNode.newInstance(card: e.card, delegate: self)
                let drawAction = self.handNode.addCardAndAnimationIntoPosiiton(cardNode: cardNode)
                self.scene.run(drawAction) {
                    self.battleState.eventHandler.popAndHandle(battleState: self.battleState)
                }
                
            case .discardCard(let e):
                // Animate the card going to the discard
                
                if let cardNode = self.scene.getFirst(fn: { (node) -> Bool in
                    (node as? CardNode)?.card.uuid == e.card.uuid
                }) {
                    // TODO: Make a better discard action
                    
                    let discardAction = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
                    cardNode.run(discardAction, completion: {
                        self.battleState.eventHandler.popAndHandle(battleState: self.battleState)
                    })
                } else {
                    self.battleState.eventHandler.popAndHandle(battleState: self.battleState)
                }
                
            case .playerInputRequired:
                break
                
            default:
                self.battleState.eventHandler.popAndHandle(battleState: self.battleState)
                
            
            }
        }
        
        return false
    }
}


extension SKNode {
    
    func getFirst(fn: (SKNode) -> Bool) -> SKNode? {
        
        if fn(self) {
            return self
        
        } else {
            for c in self.children {
                if let found =  c.getFirst(fn: fn) {
                    return found
                }
            }
            return nil
        }
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
