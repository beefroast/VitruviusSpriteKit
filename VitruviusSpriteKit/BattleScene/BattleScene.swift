//
//  BattleScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 8/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

protocol BattleSceneDelegate: AnyObject {
    func onBattleWon(sender: BattleScene)
    func onBattleLost(sender: BattleScene)
}

class BattleScene: SKScene, EndTurnButtonDelegate, CardNodeTouchDelegate, EventHandlerDelegate {

    

    weak var battleSceneDelegate: BattleSceneDelegate? = nil
    
    enum State {
        case waitingForAnimation
        case waitingForPlayerAction
        case draggingCard(CardNode, SKNode)
        case selectingTarget(CardNode, SKNode)
    }

    
    var battleState: BattleState!
    var state: State = .waitingForAnimation
    
    var handNode: HandNode!
    var playArea: PlayAreaNode!
    var discardNode: SKNode!
    var drawNode: SKNode!
    var endTurnButton: EndTurnButton!
    var cardNodePool: CardNodePool!
    var arrow: ArrowNode!
    var touchNode: SKNode!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setBattleState(battleState: BattleState) {
        
        self.battleState = battleState
        
        // Generate the card nodes to be re-used...
        self.cardNodePool = CardNodePool()
        
        // Get the draw and discard nodes
        self.drawNode = self.childNode(withName: "deckNode")
        self.discardNode = self.childNode(withName: "discardNode")
        self.endTurnButton = self.childNode(withName: "endTurn") as? EndTurnButton
        self.endTurnButton.isUserInteractionEnabled = true
        self.endTurnButton.delegate = self
        
        // Add the hand node
        let handNode = HandNode()
        handNode.setupNodes()
        handNode.zPosition = 20.0
        self.handNode = handNode
        self.addChild(handNode)
        handNode.position = CGPoint(x:0, y: -200)
        
        // Make an actor node for each entity in the state

        // Let's add some actors
        let playArea = PlayAreaNode()
        self.addChild(playArea)
        playArea.position = CGPoint.zero

        
        let playerActorNode = ActorNode.newInstance(actor: self.battleState.player)
        playerActorNode.image?.texture = SKTexture(image: UIImage(named: "Adventurer")!)
        
        let enemyNodes = self.battleState.enemies.map { (enemy) -> ActorNode in
            return ActorNode.newInstance(actor: enemy)
        }
        
        playArea.addPlayerAndEnemies(player: playerActorNode, enemies: enemyNodes)
        
        self.playArea = playArea
        
        // Add the arrow node
        self.arrow = ArrowNode()
        self.addChild(self.arrow)
        
        // Add a node that will move in response to the player's touching
        self.touchNode = SKNode()
        self.addChild(self.touchNode)
        
        self.arrow.tipNode = self.touchNode
        
        // Make ourselves the delegate
        battleState.eventHandler.delegate = self
        
        // Push the battle began event
        self.battleState.eventHandler.push(event: Event.onBattleBegan)
        
        // Now pop the first event of the stack
        battleState.popNext()
    }
    
    var lastTime: TimeInterval = 0
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - lastTime
        self.arrow.updateWithTimeInterval(timeInterval: deltaTime)
        self.lastTime = currentTime
    }
    
    
    // MARK: - EventHandlerDelegate Implementation
    
    
    func onEvent(sender: EventHandler, battleState: BattleState, event: Event) {
           
        let state = battleState
        
           DispatchQueue.main.async {
                           
               switch event {
                   
                   
               case .onEnemyPlannedTurn(let e):
                   
                   // Get the enemy that has planned their turn
                guard let enemyNode = self.playArea.actorNode(withUuid: e.enemyUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   enemyNode.setIntentionToEvents(battleState: state, events: e.events)
                   self.battleState.popNext()
                   
               case .onCardDrawn(let e):
                   
                   guard let card = state.player.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   // Raise the hand
                   self.handNode.run(SKAction.moveTo(y: -200, duration: 0.2))

                   // Make the card
                   let cardNode = self.cardNodePool.getFromPool()
                   cardNode.setupWith(card: card, delegate: self)
                   self.drawNode.addChild(cardNode)
                   
                   cardNode.setScale(0.2)
                   cardNode.alpha = 0.0
                   cardNode.position = CGPoint.zero
                   cardNode.zRotation = 0.0
                   
                   let drawAction = self.handNode.addCardAndAnimationIntoPosiiton(cardNode: cardNode)
                   self.run(drawAction) {
                       self.battleState.popNext()
                   }
                   
                   // Update the count on the draw pile
                   if let label = self.drawNode.childNode(withName: "count") as? SKLabelNode {
                       label.text = "\(self.battleState.player.cardZones.drawPile.count)"
                   }
                   
               case .discardCard(let e):
    
                   
                   // Find the card
                   guard let cardNode = self.getFirstRecursive(fn: { (node) -> Bool in
                       (node as? CardNode)?.card.uuid == e.cardUuid
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
                       self.cardNodePool.returnToPool(cardNode: cardNode as! CardNode)
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
                   
                   guard let actor = state.actorWith(uuid: e.actorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   if actor.faction == .player {
                       self.handNode.setCardsInteraction(enabled: false)
                       self.endTurnButton.isUserInteractionEnabled = false
                   }
                   self.battleState.popNext()
                   
               case .onTurnBegan(let e):
                   
                   guard let actor = state.actorWith(uuid: e.actorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   if actor.faction != .player {
                       self.handNode.run(SKAction.moveTo(y: -400, duration: 0.2))
                   } else {
                       
                       // Show that it's your turn
                       let yourTurnNode = SKLabelNode.init(text: "Your turn")
                       self.addChild(yourTurnNode)
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
                   self.handNode.setCardsInteraction(enabled: true)
                   self.endTurnButton.isUserInteractionEnabled = true
                
                    let x = try! JSONEncoder.init().encode(battleState)
                    let s = String(data: x, encoding: .utf8)!
                    print(s)
                   
               case .didLoseHp(let e):
                   
                   guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   guard let actorNode = self.playArea.actorNode(withUuid: actor.uuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   // Bulge
                   actorNode.isPaused = false
                   actorNode.setScale(1.05)
                   actorNode.run(SKAction.scale(to: 1.0, duration: 0.1)) {
                   }
                   
                   // Update the HP bar
                   let newWidth = 130.0 * (CGFloat(actor.body.hp) / CGFloat(actor.body.maxHp))
                   actorNode.healthBar?.size = CGSize(
                       width: newWidth,
                       height: actorNode.healthBar?.size.height ?? 0
                   )
                   actorNode.healthBarText?.text = "\(actor.body.hp)/\(actor.body.maxHp)"
                   
                   // Show a hit counter
                   let label = SKLabelNode(text: "\(e.amount)")
                   label.position = actorNode.getGlobalPosition()
                   label.attributedText = FontHandler().getDamageText(amount: e.amount)
                   
                   self.addChild(label)
                   label.run(SKAction.sequence([
                       SKAction.group([
                           SKAction.moveBy(x: 0, y: 100, duration: 0.2),
                           SKAction.scale(by: 1.5, duration: 0.2)
                       ]),
                       SKAction.fadeAlpha(to: 0, duration: 0.2)
                   ])) {
                       label.removeFromParent()
                   }
                   
                   self.battleState.popNext()
                   
               case .didLoseBlock(let e):
                   guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                       actorNode.setBlock(amount: actor.body.block)
                   }
                   self.battleState.popNext()
                   
               case .didGainHp(let e):
                   guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                       actorNode.details?.text = actor.body.description
                   }
                   self.battleState.popNext()
                   
               case .didGainBlock(let e):
                   guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                       self.battleState.popNext()
                       return
                   }
                   if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                       actorNode.setBlock(amount: actor.body.block)
                   }
                   self.battleState.popNext()
                   
               case .attack(let e):
                   guard let ownerActor = state.actorWith(uuid: e.sourceOwner) else {
                       self.battleState.popNext()
                       return
                   }
                   guard let actorNode = self.playArea.actorNode(withUuid: ownerActor.uuid) else {
                       self.battleState.popNext()
                       return
                   }
                   
                   actorNode.isPaused = false
                   
                   let xBump: CGFloat = ownerActor.faction == .player ? 40.0 : -40.0
                   
                   actorNode.run(SKAction.moveBy(x: xBump, y: 0, duration: 0.1)) {
                       self.battleState.popNext()
                       DispatchQueue.main.async {
                           actorNode.run(SKAction.moveBy(x: -xBump, y: 0, duration: 0.1))
                       }
                   }
                   
               case .onEnemyDefeated(let e):
                   guard let a = self.playArea.actorNode(withUuid: e.actorUuid) else {
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
                   self.addChild(label)
                   
                   // Fade out everything
                   self.isUserInteractionEnabled = false
                   self.run(SKAction.fadeOut(withDuration: 1.0))
                
                   
               default:
                   self.battleState.popNext()
                   
               
               }
           }
           
           return
       }
    
    // MARK: - EndTurnButtonDelegate Implementation
    
    func endTurnPressed(button: EndTurnButton) {
        self.battleState.eventHandler.push(event:
            Event.onTurnEnded(ActorEvent.init(actorUuid: self.battleState.player.uuid))
        )
        self.battleState.popNext()
    }
    
    // MARK: - CardNodeTouchDelegate Implementation
    
    func touchesBegan(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
          
        self.touchNode.position =  touches.first!.location(in: self)
        
        self.state = .draggingCard(card, card.parent!)
            
        // Move the hand down...
        let a = SKAction.moveTo(y: -400, duration: 0.2)
        self.handNode.run(a)
        card.zPosition = 100

        self.handNode.removeCardAndAnimateIntoPosition(cardNode: card)
        self.touchNode.addChildPreserveTransform(child: card)

        card.run(SKAction.group([
            SKAction.rotate(toAngle: 0, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        
      }
    
      func touchesMoved(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
          
        self.touchNode.position =  touches.first!.location(in: self)
        
        switch self.state {
            
        case .draggingCard(let cardNode, let previousParentNode):
            
            if self.touchNode.position.y >= -100 && card.card.requiresSingleTarget {
                self.state = .selectingTarget(cardNode, previousParentNode)
                self.addChildPreserveTransform(child: cardNode)
                card.run(SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1))
                self.arrow.isHidden = false
                self.arrow.tailNode = card
                self.arrow.tipNode = self.touchNode
                self.arrow.updateArrow()
            
            } else {
                self.arrow.isHidden = true
                self.arrow.tipNode = nil
                self.arrow.tailNode = nil
            }
            
        case .selectingTarget(let cardNode, let previousParentNode):
            
            if self.touchNode.position.y < -100 {
                self.state = .draggingCard(cardNode, previousParentNode)
                self.touchNode.addChildPreserveTransform(child: cardNode)
                card.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.1))
                self.arrow.isHidden = true
                self.arrow.tipNode = nil
                self.arrow.tailNode = nil
                
            } else {
                self.arrow.isHidden = false
                self.arrow.tailNode = card
                self.arrow.tipNode = self.touchNode
                self.arrow.updateArrow()
            }
            
        default:
            break
            
        }
      }
      
    func touchesEnded(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
        
        self.touchNode.position =  touches.first!.location(in: self)

        if self.touchNode.position.y >= -100 {
            
            guard card.requiresSingleTarget() else {
                
                // We don't need to check for a valid target, we can just play the card...
                self.state = .waitingForPlayerAction
                self.battleState.eventHandler.push(
                    event: Event.playCard(
                        PlayCardEvent.init(
                            actorUuid: self.battleState.player.uuid,
                            cardUuid: card.card.uuid
                        )
                    )
                )
                self.battleState.popNext()
                return
                
            }
            
            // Hide the arrow
            self.arrow.isHidden = true
            self.arrow.tipNode = nil
            self.arrow.tailNode = nil
            
            // Make sure we have a valid target to play the card against
              let draggedTo = touches.first!.location(in: self)
              let nodes = self.nodes(at: draggedTo)
              
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
            
            
            self.battleState.eventHandler.push(event: Event.playCard(PlayCardEvent.init(
                actorUuid: self.battleState.player.uuid,
                cardUuid: card.card.uuid,
                target: actorNode.actorUuid
            )))
                
            self.battleState.popNext()
            
            
        } else {
            
            // Put the card back in the hand & move the hand up
            self.handNode.addCardAndAnimationIntoPosiiton(cardNode: card)
            let a = SKAction.moveTo(y: -200, duration: 0.2)
            self.handNode.run(a)
            self.state = .waitingForPlayerAction
        }
        
        
    }

    
      
      

      
      func touchesCancelled(card: CardNode, touches: Set<UITouch>, with event: UIEvent?) {
          
      }
    
}
