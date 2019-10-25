//
//  RandomNumberGenerator.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 15/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import GameKit

class SeededRandomNumberGenerator: RandomNumberGenerator, Codable {
    
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
    

    func next() -> UInt64 {
        
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
        let n = self.next()
        return n % exclusiveUpperBound
    }
    
    func nextInt(exclusiveUpperBound: Int) -> Int {
        return Int(self.nextInt(exclusiveUpperBound: UInt64(exclusiveUpperBound)))
    }
    
    
    
    
}

class RandomnessSource: Codable {
    
    let drawRng: LinearCongruentialGenerator
    let enemyRng: LinearCongruentialGenerator
    let rewardRng: LinearCongruentialGenerator
    let missionRng: LinearCongruentialGenerator
    
    init(s: UInt32) {
        
        let rng = LinearCongruentialGenerator(s: s)
        
        self.drawRng = LinearCongruentialGenerator.init(s: rng.next32())
        self.enemyRng = LinearCongruentialGenerator.init(s: rng.next32())
        self.rewardRng = LinearCongruentialGenerator.init(s: rng.next32())
        self.missionRng = LinearCongruentialGenerator.init(s: rng.next32())
        
    }
    
}

class LinearCongruentialGenerator: Codable, RandomNumberGenerator {
    
    let a: UInt32 = 1664525
    let c: UInt32 = 1013904223
    var s: UInt32
    
    init(s: UInt32) {
        self.s = s
    }
    
    func next32() -> UInt32 {
        self.s = (a &* s) &+ c
        return s
    }
    
    func next() -> UInt64 {
        return UInt64(next32())
    }
    
    func nextInt(exclusiveUpperBound: UInt64) -> UInt64 {
        let x = next()
        return x % exclusiveUpperBound
    }
    
    func nextInt(exclusiveUpperBound: Int) -> Int {
        let x = Int(next32())
        return x % exclusiveUpperBound
    }
    
}
