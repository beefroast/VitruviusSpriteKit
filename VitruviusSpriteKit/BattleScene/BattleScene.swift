//
//  BattleScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 8/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit

protocol BattleSceneDelegate: AnyObject {
    func onBattleWon(sender: BattleScene)
    func onBattleLost(sender: BattleScene)
    func onSelectedReward(sender: BattleScene, card: Card?)
}

class BattleScene: SKScene, EndTurnButtonDelegate, CardNodeTouchDelegate, ChooseRewardNodeDelegate, EventQueueHandlerDelegate {
    
    

    weak var battleSceneDelegate: BattleSceneDelegate? = nil
    
    enum State {
        case waitingForAnimation
        case waitingForPlayerAction
        case draggingCard(CardNode, SKNode)
        case selectingTarget(CardNode, SKNode)
    }

    
    var gameState: GameState!
    var battleState: BattleState { get { return self.gameState.currentBattle! }}
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
    
    func setGameState(gameState: GameState) {
        
        self.gameState = gameState
        
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
        
        self.gameState.currentBattle!.eventHandler.delegate = self
        
        self.currentAnimationPromise = Promise<Void>.value(())
        
        // Now pop the first event of the stack
        self.popAndHandle()

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
    
    var currentAnimationPromise: Promise<Void> = Promise<Void>.value(())
    
    func blockOnAnimation(then: @escaping () -> Void) {
        self.currentAnimationPromise = self.currentAnimationPromise.done(then)
    }
    
    func updateGameStateThenPop() {
        self.battleState.eventHandler.popAndHandle(state: self.gameState)
        self.popAndHandle()
    }
    
    func popAndHandle()  {
        
        guard let event = self.battleState.eventHandler.hasCurrentEvent() else {
            
            // There is no next event, so let's wait until our current animation stack is finished
            // And then push a tick...
            
            self.blockOnAnimation {
                self.battleState.eventHandler.push(event: EventType.tick)
                self.updateGameStateThenPop()
                return
            }
            return
        }
        
        let state = self.battleState
        
        switch event {
            
        case .tick:
            self.blockOnAnimation {
                self.updateGameStateThenPop()
            }
            
          case .onCardDrawn(let e):
            
            self.blockOnAnimation {
             
                guard let card = state.player.cardZones.hand.cardWith(uuid: e.cardUuid) else {
                    self.updateGameStateThenPop()
                    return
                }
                
                // Raise the hand
                self.handNode.run(SKAction.moveTo(y: -200, duration: 0.2))

                // Make the card
                let cardNode = self.cardNodePool.getFromPool()
                cardNode.isUserInteractionEnabled = false
                cardNode.setupWith(card: card, delegate: self)
                cardNode.removeFromParent()
                self.drawNode.addChild(cardNode)
                
                cardNode.setScale(0.2)
                cardNode.alpha = 0.0
                cardNode.position = CGPoint.zero
                cardNode.zRotation = 0.0
                
                let drawAction = self.handNode.addCardAndAnimationIntoPosiiton(cardNode: cardNode)
                self.run(drawAction) {
                    self.updateGameStateThenPop()
                }
                
                // Update the count on the draw pile
                if let label = self.drawNode.childNode(withName: "count") as? SKLabelNode {
                    label.text = "\(self.battleState.player.cardZones.drawPile.count)"
                }
            }
              
          case .discardCard(let e):

              // Find the card
              guard let cardNode = self.getFirstChildRecursive(fn: { (node) -> Bool in
                  (node as? CardNode)?.card.uuid == e.cardUuid
              }) else {
                  self.updateGameStateThenPop()
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
              self.updateGameStateThenPop()
              
          case .shuffleDiscardIntoDrawPile(_):
              
              // Update the count on the draw pile
              if let label = self.drawNode.childNode(withName: "count") as? SKLabelNode {
                  label.text = "\(self.battleState.player.cardZones.drawPile.count)"
              }
              
              // Update the count on the discard pile
              if let label = self.discardNode.childNode(withName: "count") as? SKLabelNode {
                  label.text = "\(self.battleState.player.cardZones.discard.getCount())"
              }
              
              self.updateGameStateThenPop()
              
        case .refreshHand:
            self.updateGameStateThenPop()
              
          case .playerInputRequired:
              self.handNode.run(SKAction.moveTo(y: -200, duration: 0.2))
              self.handNode.setCardsInteraction(enabled: true)
              self.endTurnButton.isUserInteractionEnabled = true
               
              // Enable/disable each card depending on if we can afford it or not...
              self.handNode.cards.forEach { (cardNode) in
                   cardNode.isUserInteractionEnabled = true
              }
              self.battleState.eventHandler.popAndHandle(state: self.gameState)

              
          case .didLoseHp(let e):
              
              guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                  self.updateGameStateThenPop()
                  return
              }
              
              guard let actorNode = self.playArea.actorNode(withUuid: actor.uuid) else {
                  self.updateGameStateThenPop()
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
              
              self.updateGameStateThenPop()
              
          case .didLoseBlock(let e):
              guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                  self.popAndHandle()
                  return
              }
              
              if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                  actorNode.setBlock(amount: actor.body.block)
              }
              self.updateGameStateThenPop()
              
          case .didGainHp(let e):
              guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                  self.popAndHandle()
                  return
              }
              if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                  actorNode.details?.text = actor.body.description
              }
              self.updateGameStateThenPop()
              
          case .didGainBlock(let e):
              guard let actor = state.actorWith(uuid: e.targetActorUuid) else {
                  self.popAndHandle()
                  return
              }
              if let actorNode = self.playArea.actorNode(withUuid: actor.uuid) {
                  actorNode.setBlock(amount: actor.body.block)
              }
              self.updateGameStateThenPop()
           
          case .willLoseMana(let e):
           if let label = self.manaNode.childNode(withName: "count") as? SKLabelNode {
               label.text = "\(self.battleState.player.currentMana)"
           }
           self.updateGameStateThenPop()
           
          case .willGainMana(let e):
           if let label = self.manaNode.childNode(withName: "count") as? SKLabelNode {
               label.text = "\(self.battleState.player.currentMana)"
           }
           self.updateGameStateThenPop()
              
          case .attack(let e):
              guard let ownerActor = state.actorWith(uuid: e.sourceOwner) else {
                  self.updateGameStateThenPop()
                  return
              }
              guard let actorNode = self.playArea.actorNode(withUuid: ownerActor.uuid) else {
                  self.updateGameStateThenPop()
                  return
              }
              
              actorNode.isPaused = false
              
              let xBump: CGFloat = ownerActor.faction == .player ? 40.0 : -40.0
              
              actorNode.run(SKAction.moveBy(x: xBump, y: 0, duration: 0.1)) {
                  self.updateGameStateThenPop()
                  DispatchQueue.main.async {
                      actorNode.run(SKAction.moveBy(x: -xBump, y: 0, duration: 0.1))
                  }
              }
              
          case .onEnemyDefeated(let e):
              guard let a = self.playArea.actorNode(withUuid: e.actorUuid) else {
                  self.updateGameStateThenPop()
                  return
              }
              a.run(SKAction.fadeAlpha(to: 0.0, duration: 0.1)) {
                  a.removeFromParent()
                  self.updateGameStateThenPop()
              }
            
        case .turnBegan(let uuid):
            self.updateGameStateThenPop()
              
          case .onBattleWon:
              
           self.battleSceneDelegate?.onBattleWon(sender: self)
           self.handNode.setCardsInteraction(enabled: false)
           
          case .destroyCard(let e):
           
           // Find the card
           guard let cardNode = self.getFirstChildRecursive(fn: { (node) -> Bool in
               (node as? CardNode)?.card.uuid == e.cardUuid
           }) else {
               self.updateGameStateThenPop()
               return
           }
           
           // Remove from the hand
           self.handNode.removeCardAndAnimateIntoPosition(cardNode: cardNode as! CardNode)
           
           // Animate it disappearing
           let discardAction = SKAction.group([
               SKAction.fadeAlpha(to: 0.0, duration: 0.2),
               SKAction.scale(by: 0.0, duration: 0.2)
           ])
           
           cardNode.run(discardAction) {
               self.cardNodePool.returnToPool(cardNode: cardNode as! CardNode)
           }

           
           // Destroying doesn't block
           self.updateGameStateThenPop()
           
          case .expendCard(let e):
           
           // Find the card
           guard let cardNode = self.getFirstChildRecursive(fn: { (node) -> Bool in
               (node as? CardNode)?.card.uuid == e.cardUuid
           }) else {
               self.updateGameStateThenPop()
               return
           }
           
           // Remove from the hand
           self.handNode.removeCardAndAnimateIntoPosition(cardNode: cardNode as! CardNode)
           
           // Animate it disappearing
           let discardAction = SKAction.group([
               SKAction.fadeAlpha(to: 0.0, duration: 0.2),
               SKAction.scale(by: 0.0, duration: 0.2)
           ])
           
           cardNode.run(discardAction) {
               self.cardNodePool.returnToPool(cardNode: cardNode as! CardNode)
           }

           
           // Destroying doesn't block
           self.updateGameStateThenPop()
           
          case .upgradeCard(let e):
           
           // Make sure the card has the upgraded text (TODO: Add a visual effect for an upgrade)
           
           // Find the card and node
           guard let card = battleState.actorWith(uuid: e.actorUuid)?.cardZones.hand.cardWith(uuid: e.cardUuid),
               let cardNode = self.getFirstChildRecursive(fn: { (node) -> Bool in (node as? CardNode)?.card.uuid == e.cardUuid }) as? CardNode else {
                   self.popAndHandle()
                   return
           }
           
           cardNode.setupWith(card: card, delegate: self)
           
           self.updateGameStateThenPop()
           
           case .playCard(_):
               self.handNode.setCardsInteraction(enabled: false)
               self.updateGameStateThenPop()
            
        case .cancelChanelledEvent(let uuid): fallthrough
          case .onBattleBegan: fallthrough
          case .addEffect(_): fallthrough
          case .removeEffect(_): fallthrough
          case .willDrawCards(_): fallthrough
          case .drawCard(_): fallthrough
          case .discardHand(_): fallthrough
          case .willLoseHp(_): fallthrough
          case .willLoseBlock(_): fallthrough
          case .willGainHp(_): fallthrough
          case .willGainBlock(_): fallthrough
        case .concentrationBroken(_): fallthrough
        case .chanelledEvent(_): fallthrough
          case .onBattleLost:
            self.updateGameStateThenPop()
        
        }
    }
    
    // MARK: - EndTurnButtonDelegate Implementation
    
    func endTurnPressed(button: EndTurnButton) {
        self.battleState.eventHandler.push(event: EventType.refreshHand)
        self.popAndHandle()
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
                    event: EventType.playCard(
                        PlayCardEvent.init(
                            actorUuid: self.battleState.player.uuid,
                            cardUuid: card.card.uuid
                        )
                    )
                )
                self.popAndHandle()
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
            
            
            self.battleState.eventHandler.push(event: EventType.playCard(PlayCardEvent.init(
                actorUuid: self.battleState.player.uuid,
                cardUuid: card.card.uuid,
                target: actorNode.actorUuid
            )))
                
            self.popAndHandle()
            
            
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
    
    
    // MARK: - EventQueueHandlerDelegate Implementation
    
    func eventQueue(handler: EventQueueHandler, enqueued: EventType, withPriority: Int) {
        print("WE CARE ABOUT: \(enqueued)")
    }
    
}



class EventQueuePrinterEffect: EffectStrategy {
    
    func actorNameFor(uuid: UUID?, gameState: GameState) -> String {
        return uuid.flatMap(gameState.currentBattle!.actorWith(uuid:))?.name ?? "(Unknown)"
    }
    
    func handle(effect: Effect, event: EventType, gameState: GameState) -> EffectResult {
        
        switch event {
        
        case .tick:
            print("Tick")
            
        case .playerInputRequired:
            print("Player input required")
            
        case .onBattleBegan:
            print("Battle began")
            
        case .turnBegan(let uuid):
            print("\(actorNameFor(uuid: uuid, gameState: gameState))'s turn began")
            
        case .addEffect(let effect):
            print("Adding effect: \(effect.uuid)")
            
        case .removeEffect(let effect):
            print("Removing effect: \(effect.uuid)")
            
        case .willDrawCards(let e):
            print("\(actorNameFor(uuid: e.actorUuid, gameState: gameState)) will draw \(e.amount) cards.")
            
        case .drawCard(let e):
            print("\(actorNameFor(uuid: e.actorUuid, gameState: gameState)) draws card.")
            
        case .onCardDrawn(let e):
            print("\(actorNameFor(uuid: e.actorUuid, gameState: gameState)) drew card.")
            
        case .discardCard(let e):
            break
            
        case .discardHand(let e):
            break
            
        case .destroyCard(let e):
            break
            
        case .expendCard(let e):
            break
            
        case .upgradeCard(let e):
            break
            
        case .shuffleDiscardIntoDrawPile(let e):
            break
            
        case .refreshHand:
            break
            
        case .willLoseHp(let e):
            break
            
        case .willLoseBlock(let e):
            break
            
        case .didLoseHp(let e):
            break
            
        case .didLoseBlock(let e):
            break
            
        case .willGainHp(let e):
            break
            
        case .willGainBlock(let e):
            break
            
        case .didGainHp(let e):
            break
            
        case .didGainBlock(let e):
            break
            
        case .willGainMana(let e):
            break
            
        case .willLoseMana(let e):
            break
            
        case .playCard(let e):
            break
            
        case .attack(let e):
            break
            
        case .onEnemyDefeated(let e):
            break
            
        case .concentrationBroken(let e):
            break
            
        case .chanelledEvent(let e):
            break
            
        case .cancelChanelledEvent(let e):
            break
            
        case .onBattleWon:
            break
            
        case .onBattleLost:
            break
            
        }
    
        return EffectResult.noChange
    }
    
    
    
    
}
