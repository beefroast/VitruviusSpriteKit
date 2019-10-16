//
//  CardOfferer.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 15/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class CardOfferer {
    
    var mythicChance: Int = -10
    var rareChance: Int = 0
    var uncommonChance: Int = 20
    
    func randomlyGetRarity(challengeRating: Int, rng: RandomNumberGenerator) -> CardRarity {
        
        // Get a random number between 0 and 99, modify it with the
        // challenge rating
        let r = max(0, rng.nextInt(exclusiveUpperBound: 100) - challengeRating)
        
        let nonNegativeMythicChance = max(0, mythicChance)
        
        if (r < nonNegativeMythicChance) {
            return .mythic
        } else if (r < (nonNegativeMythicChance + rareChance)) {
            return .rare
        } else if (r < (nonNegativeMythicChance + rareChance + uncommonChance)) {
            return .uncommon
        } else {
            return .common
        }
    }
    
    func getRarityAndAdjustWeights(challengeRating: Int, rng: RandomNumberGenerator) -> CardRarity {
        let rarity = self.randomlyGetRarity(challengeRating: challengeRating, rng: rng)
        self.mythicChance = (rarity == .mythic) ? -10 : self.mythicChance + 1
        self.rareChance = (rarity == .rare) ? 0 : self.rareChance + 1
        self.uncommonChance = (rarity == .uncommon) ? 20 : self.uncommonChance + 1
        return rarity
    }
    
//    func getCardOfferFor(challengeRating: Int, rng: RandomNumberGenerator) -> Card {
//
//        switch self.getRarityAndAdjustWeights(challengeRating: challengeRating, rng: rng) {
//            case
//        }
//
//
//
//    }
    
}
