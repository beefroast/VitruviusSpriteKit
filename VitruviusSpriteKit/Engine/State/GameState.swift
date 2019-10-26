//
//  GameState.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class GameState: Codable {
    
    var random: RandomnessSource
    var playerData: PlayerData
    var buildings: [Building]
    var daysUntilNextBoss: Int
    var currentMission: Mission?
    var currentBattle: BattleState?
    
    init(
        random: RandomnessSource,
        playerData: PlayerData,
        buildings: [Building],
        daysUntilNextBoss: Int,
        currentMission: Mission?,
        currentBattle: BattleState?) {
        
        self.random = random
        self.playerData = playerData
        self.buildings = buildings
        self.daysUntilNextBoss = daysUntilNextBoss
        self.currentMission = currentMission
        self.currentBattle = currentBattle
    }
    
    static func newGameWith(name: String, characterClass: CharacterClass) -> GameState {
        return GameState.init(
            random: RandomnessSource.newInstance(),
            playerData: PlayerData.newPlayerFor(name: name, characterClass: characterClass),
            buildings: [
                BTTavern().newInstance(),
                BTJoinery().newInstance()
            ],
            daysUntilNextBoss: 30,
            currentMission: nil,
            currentBattle: nil
        )
    }
}
