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
    
    func randomlyGetRarity(challengeRating: Int, rng: SeededRandomNumberGenerator) -> CardRarity {
        
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
    
    func getRarityAndAdjustWeights(challengeRating: Int, rng: SeededRandomNumberGenerator) -> CardRarity {
        let rarity = self.randomlyGetRarity(challengeRating: challengeRating, rng: rng)
        self.mythicChance = (rarity == .mythic) ? -10 : self.mythicChance + 1
        self.rareChance = (rarity == .rare) ? 0 : self.rareChance + 1
        self.uncommonChance = (rarity == .uncommon) ? 20 : self.uncommonChance + 1
        return rarity
    }

    
    func getCardOffer(challengeRating: Int, rng: SeededRandomNumberGenerator, classes: CardClasses) -> Card {
        
        // Get a card rarity
        let rarity = self.getRarityAndAdjustWeights(challengeRating: challengeRating, rng: rng)
        
        let choices = allCardStrategies().filter { (cs) -> Bool in
            cs.rarity == rarity && cs.classes.isSubset(of: classes)
        }
        
        if choices.count == 0 {
            // Safety strike
            // TODO: Make sure there's at least one card in each rarity with each class
            return CSStrike().instance()
        }
        
        // Get a random card from the choices
        let cardStrategy = choices.randomElement(rng: rng)
        
        // TODO: Might want to be able to get upgraded cards at some point
        return cardStrategy.instance()
    }
    
    func getCards(rng: inout SeededRandomNumberGenerator, classes: CardClasses, attributes: CardAttributes, amount: Int) -> [Card] {
        
        var choices = allCardStrategies().filter { (cs) -> Bool in
            return cs.classes.isSubset(of: classes)
                && cs.attributes.isSuperset(of: attributes)
        }
        
        choices.shuffle(using: &rng)
        
        let slice = choices.prefix(amount).map({ $0.instance() })
        
        return Array(slice)
    }
    
    func allCardStrategies() -> [CardStrategy] {
        
        return [
            CSStrike(),
            CSDefend(),
            CSHealthPotion(),
            CSMasteryPotion(),
            CSBlockPotion(),
        ]
        
    }
    
    
    
    
}

extension Array {
    
    func randomElement(rng: SeededRandomNumberGenerator) -> Element {
        return self[rng.nextInt(exclusiveUpperBound: self.count)]
    }
}
