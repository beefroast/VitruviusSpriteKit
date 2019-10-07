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
    case selectingTarget(CardNode, SKNode)
}

class GameViewController: UIViewController, CardNodeTouchDelegate, IEffect, EndTurnButtonDelegate {
 
    var handNode: HandNode!
    var playArea: PlayAreaNode!
    var battleState: BattleState!
    var discardNode: SKNode!
    var drawNode: SKNode!
    var endTurnButton: EndTurnButton!
    
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
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        
        // Get the draw and discard nodes
        self.drawNode = scene?.childNode(withName: "deckNode")
        self.discardNode = scene?.childNode(withName: "discardNode")
        self.endTurnButton = scene?.childNode(withName: "endTurn") as! EndTurnButton
        self.endTurnButton.isUserInteractionEnabled = true
        self.endTurnButton.delegate = self
        
        // Add the hand node
        let handNode = HandNode()
        handNode.setupNodes()
        handNode.zPosition = 20.0
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

        let playerActorNode = ActorNode.newInstance(actor: player)
        playerActorNode.image?.texture = SKTexture(image: UIImage(named: "Adventurer")!)
        
        playArea.addPlayerAndEnemies(
            player: playerActorNode,
            enemies: [
                ActorNode.newInstance(actor: goomba),
                ActorNode.newInstance(actor: koopa)
            ]
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
        card.zPosition = 100
  
        self.handNode.removeCardAndAnimateIntoPosition(cardNode: card)
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
                
                // Check to see if we dragged onto a target
                let draggedTo = touches.first!.location(in: self.scene)
                let nodes = self.scene.nodes(at: draggedTo)
                
                guard let actorNode = nodes.compactMap({ $0 as? ActorNode }).first,
                    let actor = self.battleState.enemies.first(where: { (e) -> Bool in
                        e.uuid == actorNode.actorUuid
                    }) else {
                        
                        // Put the card back in the hand & move the hand up
                        self.handNode.addCardAndAnimationIntoPosiiton(cardNode: card)
                        let a = SKAction.moveTo(y: -200, duration: 0.2)
                        self.handNode.run(a)
                        self.state = .waitingForPlayerAction
                        return
                }
                
                self.state = .waitingForPlayerAction
                self.battleState.eventHandler.push(event: Event.playCard(
                    CardEvent.init(
                        cardOwner: self.battleState.player,
                        card: card.card,
                        target: actor
                    )
                ))
                self.battleState.popNext()
                
                
            } else {
                
                // Just play the card...
                self.state = .waitingForPlayerAction
                self.battleState.eventHandler.push(
                    event: Event.playCard(CardEvent.init(cardOwner: self.battleState.player, card: card.card))
                )
                self.battleState.popNext()
                
            }
            
        } else {
            
            // Put the card back in the hand & move the hand up
            self.handNode.addCardAndAnimationIntoPosiiton(cardNode: card)
            let a = SKAction.moveTo(y: -200, duration: 0.2)
            self.handNode.run(a)
            self.state = .waitingForPlayerAction
            
        }
    }
    
    func touchesMoved(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
        switch self.state {
        case .draggingCard(let c, let p):
            
            if card.position.y >= -100 && card.card.requiresSingleTarget {
                self.state = .selectingTarget(c, p)
                card.run(SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1))
            } else {
                card.position = touches.first!.location(in: card.parent!)
            }
            
        case .selectingTarget(let c, let p):
            if touches.first!.location(in: self.scene).y < -100 {
                self.state = .draggingCard(c, p)
                card.position = touches.first!.location(in: card.parent!)
            }
            
        default:
            card.position = touches.first!.location(in: card.parent!)
        }
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
                
                // Raise the hand
                self.handNode.run(SKAction.moveTo(y: -200, duration: 0.2))

                // Make the card
                let cardNode = CardNode.newInstance(card: e.card, delegate: self)
                self.drawNode.addChild(cardNode)
                
                cardNode.setScale(0.2)
                cardNode.alpha = 0.0
                cardNode.position = CGPoint.zero
                cardNode.zRotation = 0.0
                
                let drawAction = self.handNode.addCardAndAnimationIntoPosiiton(cardNode: cardNode)
                self.scene.run(drawAction) {
                    self.battleState.popNext()
                }
                
                // Update the count on the draw pile
                if let label = self.drawNode.childNode(withName: "count") as? SKLabelNode {
                    label.text = "\(self.battleState.player.cardZones.drawPile.count)"
                }
                
            case .discardCard(let e):
                // Animate the card going to the discard
                
                // Find the card
                guard let cardNode = self.scene.getFirstRecursive(fn: { (node) -> Bool in
                    (node as? CardNode)?.card.uuid == e.card.uuid
                }) else {
                    self.battleState.popNext()
                    return
                }
                
                // Remove from the hand
                self.handNode.removeCardAndAnimateIntoPosition(cardNode: cardNode as! CardNode)
                
                // Reparent to the discard node
                self.discardNode.addChildPreserveTransform(child: cardNode)
                
                // Animate it disappearing
                let discardAction = SKAction.group([
                    SKAction.fadeAlpha(to: 0.0, duration: 0.2),
                    SKAction.move(to: CGPoint.zero, duration: 0.2),
                    SKAction.scale(by: 0.2, duration: 0.2)
                ])
                
                cardNode.run(discardAction) {
                    cardNode.removeFromParent()
                }
                
                // Update the count on the discard pile
                if let label = self.discardNode.childNode(withName: "count") as? SKLabelNode {
                    label.text = "\(self.battleState.player.cardZones.discard.getCount())"
                }
                
                // Discarding doesn't block
                self.battleState.popNext()
                
            case .shuffleDiscardIntoDrawPile(_):
                
                // Update the count on the draw pile
                if let label = self.drawNode.childNode(withName: "count") as? SKLabelNode {
                    label.text = "\(self.battleState.player.cardZones.drawPile.count)"
                }
                
                // Update the count on the discard pile
                if let label = self.discardNode.childNode(withName: "count") as? SKLabelNode {
                    label.text = "\(self.battleState.player.cardZones.discard.getCount())"
                }
                
                self.battleState.popNext()
                
            case .onTurnEnded(let e):
                if e.actor.faction == .player {
                    print("DISABLED")
                    self.handNode.setCardsInteraction(enabled: false)
                    self.endTurnButton.isUserInteractionEnabled = false
                }
                self.battleState.popNext()
                
            case .onTurnBegan(let e):
                if e.actor.faction != .player {
                    self.handNode.run(SKAction.moveTo(y: -400, duration: 0.2))
                } else {
                    
                    // Show that it's your turn
                    let yourTurnNode = SKLabelNode.init(text: "Your turn")
                    self.scene.addChild(yourTurnNode)
                    yourTurnNode.run(SKAction.sequence([
                        SKAction.customAction(withDuration: 0.2, actionBlock: { (_, _) in
                            
                        }),
                        SKAction.fadeOut(withDuration: 0.2)
                    ])) {
                        yourTurnNode.removeFromParent()
                    }
                    
                }
                self.battleState.popNext()
                
            case .playerInputRequired:
                self.handNode.run(SKAction.moveTo(y: -200, duration: 0.2))
                print("ENABLED")
                self.handNode.setCardsInteraction(enabled: true)
                self.endTurnButton.isUserInteractionEnabled = true
                
            case .didLoseHp(let e):
                guard let actorNode = self.playArea.actorNode(withUuid: e.player.uuid) else {
                    self.battleState.popNext()
                    return
                }
                
                // Bulge
                actorNode.isPaused = false
                actorNode.setScale(1.05)
                actorNode.run(SKAction.scale(to: 1.0, duration: 0.1)) {
                    self.battleState.popNext()
                }
                
                // Update the HP bar
                let newWidth = 130.0 * (CGFloat(e.player.body.hp) / CGFloat(e.player.body.maxHp))
                actorNode.healthBar?.size = CGSize(
                    width: newWidth,
                    height: actorNode.healthBar?.size.height ?? 0
                )
                actorNode.healthBarText?.text = e.player.body.description
                
                // Show a hit counter
                let label = SKLabelNode(text: "\(e.amount)")
                label.position = actorNode.getGlobalPosition()
                label.attributedText = FontHandler().getDamageText(amount: e.amount)
                
                self.scene.addChild(label)
                label.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.moveBy(x: 0, y: 100, duration: 0.2),
                        SKAction.scale(by: 1.5, duration: 0.2)
                    ]),
                    SKAction.fadeAlpha(to: 0, duration: 0.2)
                ])) {
                    label.removeFromParent()
                }
                
            case .didLoseBlock(let e):
                if let actorNode = self.playArea.actorNode(withUuid: e.player.uuid) {
                    actorNode.details?.text = e.player.body.description
                }
                self.battleState.popNext()
                
            case .didGainHp(let e):
                if let actorNode = self.playArea.actorNode(withUuid: e.player.uuid) {
                    actorNode.details?.text = e.player.body.description
                }
                self.battleState.popNext()
                
            case .didGainBlock(let e):
                if let actorNode = self.playArea.actorNode(withUuid: e.player.uuid) {
                    actorNode.details?.text = e.player.body.description
                }
                self.battleState.popNext()
                
            case .attack(let e):
                guard let actorNode = self.playArea.actorNode(withUuid: e.sourceOwner.uuid) else {
                    self.battleState.popNext()
                    return
                }
                
                actorNode.isPaused = false
                actorNode.run(SKAction.moveBy(x: -40, y: 0, duration: 0.1)) {
                    self.battleState.popNext()
                    DispatchQueue.main.async {
                        actorNode.run(SKAction.moveBy(x: 40, y: 0, duration: 0.1))
                    }
                }
                
            case .onEnemyDefeated(let e):
                guard let a = self.playArea.actorNode(withUuid: e.uuid) else {
                    self.battleState.popNext()
                    return
                }
                a.run(SKAction.fadeAlpha(to: 0.0, duration: 0.1)) {
                    a.removeFromParent()
                    self.battleState.popNext()
                }
                
            case .onBattleWon:
                let label = SKLabelNode(text: "YOU WIN")
                label.fontSize = 60
                self.scene.addChild(label)
                
            default:
                self.battleState.popNext()
                
            
            }
        }
        
        return false
    }
    
    // MARK: - EndTurnButtonDelegate Implementation
    
    func endTurnPressed(button: EndTurnButton) {
        self.battleState.eventHandler.push(event: Event.onTurnEnded(PlayerEvent.init(actor: self.battleState.player)))
        self.battleState.popNext()
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
