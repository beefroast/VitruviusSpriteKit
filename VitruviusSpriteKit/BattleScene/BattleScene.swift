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
    func onSelectedReward(sender: BattleScene, card: Card?)
}

class BattleScene: SKScene, EndTurnButtonDelegate, CardNodeTouchDelegate, ChooseRewardNodeDelegate {

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
    var manaNode: SKNode!
    var endTurnButton: EndTurnButton!
    var cardNodePool: CardNodePool!
    var arrow: ArrowNode!
    var touchNode: SKNode!
    var isPickingReward: Bool = false

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
        self.manaNode = self.childNode(withName: "manaNode")
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
        playArea.position = CGPoint(x: 0, y: 80)

        
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
    

    
    func showCardSelection(cards: [Card]) -> Void {
        let node = ChooseRewardNode()
        self.addChild(node)
        node.alpha = 0.0
        node.setupWith(cards: cards, cardNodePool: self.cardNodePool)
        node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
        node.zPosition = 100
        node.delegate = self
    }
    
    // MARK: - ChooseRewardNodeDelegate Implementation
    
    func chooseReward(node: ChooseRewardNode, chose: CardNode) {
        
        if self.isPickingReward == true {
            self.battleSceneDelegate?.onSelectedReward(sender: self, card: chose.card)
            return
        }
        
        self.handNode.addCardAndAnimationIntoPosiiton(cardNode: chose)
        self.battleState.player.cardZones.hand.cards.append(chose.card)
        
        node.run(SKAction.fadeAlpha(to: 0.0, duration: 0.2)) {
            node.removeFromParent()
            chose.delegate = self
            self.handNode.setCardsInteraction(enabled: true)
        }
    }
    
    
    // MARK: - EventHandlerDelegate Implementation
    
    
//    func onEvent(sender: EventHandler, battleState: BattleState, event: Event) {
//
//        let state = battleState
//
//           fatalError()
//       }
//
//    func onEventPopped(sender: EventHandler, event: Event) {
//        self.updateEventQueueIndicator(eventHandler: sender)
//    }
//
//    func onEventPushed(sender: EventHandler, event: Event) {
//        self.updateEventQueueIndicator(eventHandler: sender)
//    }
//
//    func onEventEnqueued(sender: EventHandler, event: Event) {
//        self.updateEventQueueIndicator(eventHandler: sender)
//    }
//
//    func updateEventQueueIndicator(eventHandler: EventHandler) {
//        print("==== PRINTING EVENT STACK")
//        eventHandler.eventStack.forEach { (event) in
//            print(event)
//        }
//        print("==== EVENT STACK DONE")
//    }
    
    // MARK: - EndTurnButtonDelegate Implementation
    
    func endTurnPressed(button: EndTurnButton) {
        // Do nothing, can no longer end your turn
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
