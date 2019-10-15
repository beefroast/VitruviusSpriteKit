//
//  RandomNumberGenerator.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 15/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import GameKit

class RandomNumberGenerator: Codable {
    
    var count: UInt64
    var seed: UInt64
    
    init(count: UInt64, seed: UInt64) {
        self.count = count
        self.seed = seed
    }
    
    init() {
        self.count = 0
        self.seed = UInt64.init(Date().timeIntervalSince1970)
    }
    
    func nextInt() -> UInt64 {
        
        // Get a twister seed, ignoring overflow and just wrapping
        let twisterSeed = count &+ seed
        
        // Get a random Int
        let random = GKMersenneTwisterRandomSource.init(seed: twisterSeed).nextInt()
        
        // Bump the count ignoring overflow
        self.count = count &+ 1
        
        // Convert the Int given by the twister to a UInt64
        let randomValue = UInt64.init(bitPattern: Int64(random))
        
        // Set the seed to the last random value
        self.seed = randomValue
        
        // Return the random number
        return randomValue
    }
    
    func nextInt(exclusiveUpperBound: UInt64) -> UInt64 {
        let n = self.nextInt()
        return n % exclusiveUpperBound
    }
    
    
    
    
    
}
