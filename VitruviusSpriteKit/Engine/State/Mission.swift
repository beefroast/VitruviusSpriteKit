//
//  Mission.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

class Mission: Codable {
    
    let challengeRatingModifier: Int
    var remainingEncounters: Int
    
    init(challengeRatingModifier: Int, remainingEncounters: Int) {
        self.challengeRatingModifier = challengeRatingModifier
        self.remainingEncounters = remainingEncounters
    }
    
    func isFinished() -> Bool {
        return remainingEncounters == 0
    }
    
    func getNextEncounter(generator: EncounterGenerator, playerLevel: Int) -> Encounter? {
        if self.remainingEncounters > 0 {
            self.remainingEncounters -= 1
            return generator.generateEncounterFor(level: challengeRatingModifier + playerLevel)
        } else {
            return nil
        }
    }
    
    func calculateMissionDuration(travelTime: Int) -> Int {
        return self.remainingEncounters + travelTime
    }
    
    func placeholderName() -> String {
        return "\(self.remainingEncounters) encounters at \(challengeRatingModifier) difficulty"
    }
    
}


