//
//  BattleViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class BattleViewController: UIViewController, BattleSceneDelegate {

    var gameState: GameState!
    var battleState: BattleState!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let view: SKView = self.view as! SKView
        
        let scene = SKScene(fileNamed: "BattleScene") as! BattleScene
        scene.scaleMode = .aspectFill
        scene.setBattleState(battleState: self.gameState.currentBattle!)
        scene.battleSceneDelegate = self
        
        
        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)
    }
    
    static func newInstance(gameState: GameState) -> BattleViewController {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "battle") as! BattleViewController
        vc.gameState = gameState
        return vc
        
    }
    
    // MARK: - BattleSceneDelegate Implementation
    
    func onBattleWon(sender: BattleScene) {
        
        // Generate some cards to win
        
        let cardsOffered = self.gameState.cardOfferer.getBattleRewards(
            challengeRating: 1,
            rng: self.gameState.random.rewardRng,
            classes: self.gameState.playerData.characterClass.allowedCardClasses(),
            amount: 3
        )
        
        // TODO: Update our game state such that we're offering these cards
        sender.isPickingReward = true
        sender.showCardSelection(cards: cardsOffered)
        
        // TODO: This is shonky as..
        self.gameState.playerData.currentHp = self.gameState.currentBattle!.player.body.hp
        self.gameState.playerData.currentLevel += 1
        self.gameState.currentBattle = nil
    }
    
    func onBattleLost(sender: BattleScene) {
        // TODO: Show game over screen.
    }
    
    func onSelectedReward(sender: BattleScene, card: Card?) {
        
        // Add the selected card to the players deck
        if let c = card {
            self.gameState.playerData.decklist.append(c)
        }
        
        let enc = self.gameState.currentMission?.getNextEncounter(
            generator: EncounterGenerator(),
            playerLevel: self.gameState.playerData.currentLevel
        )
        
        // Handle the next encounter if it exists
        guard let nextEncounter = enc else {
            let vc = TownViewController.newInstance(gameState: self.gameState)
            self.navigationController?.setViewControllers([vc], animated: false)
            return
        }
        
        switch nextEncounter {
        case .battle(let enemies):
            
            let battleState = BattleState.newInstance(
                randomSource: self.gameState.random,
                player: self.gameState.playerData.newActor(),
                enemies: enemies
            )
            
            gameState.currentBattle = battleState
            let vc = BattleViewController.newInstance(gameState: gameState)
            self.navigationController?.setViewControllers([vc], animated: false)
        }
        
        
    }
}
