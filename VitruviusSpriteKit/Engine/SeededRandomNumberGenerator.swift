//
//  RandomNumberGenerator.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 15/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import GameKit

class RandomnessSource: Codable {
    
    let seed: String
    let drawRng: LinearCongruentialGenerator
    let enemyRng: LinearCongruentialGenerator
    let rewardRng: LinearCongruentialGenerator
    let missionRng: LinearCongruentialGenerator
    
    
    init(seed: String) {
        
        self.seed = seed
        
        var buckets: [String] = ["", "", "", ""]
        var bucketIndex = 0
        
        for c in seed {
            buckets[bucketIndex] = buckets[bucketIndex].appending("\(c)")
            bucketIndex = (bucketIndex + 1) % 4
        }
        
        self.drawRng = LinearCongruentialGenerator.init(s: UInt32(truncatingIfNeeded: buckets[0].consistentHash()))
        self.enemyRng = LinearCongruentialGenerator.init(s: UInt32(truncatingIfNeeded: buckets[1].consistentHash()))
        self.rewardRng = LinearCongruentialGenerator.init(s: UInt32(truncatingIfNeeded: buckets[2].consistentHash()))
        self.missionRng = LinearCongruentialGenerator.init(s: UInt32(truncatingIfNeeded: buckets[3].consistentHash()))
    }
    
    static func seedFor(date: Date = Date()) -> String {
        
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let rngSeed = UInt32(timeInterval)
        let rng = LinearCongruentialGenerator(s: rngSeed)
        let possibleCharacters = "ABCDEFGHIJKLMNOPQRSTUVWYZ"
        
        return (1...20).map { (_) -> String in
            let i = rng.nextInt(exclusiveUpperBound: possibleCharacters.count)
            let c = possibleCharacters[i]
            return "\(c)"
        }.joined()
    
    }
    
    static func newInstance() -> RandomnessSource {
        let seed = seedFor()
        return RandomnessSource(seed: seed)
    }
    

    
}

protocol RandomIntegerGenerator {
    func nextInt(exclusiveUpperBound: Int) -> Int
}


class LinearCongruentialGenerator: Codable, RandomIntegerGenerator {
    
    static let a: UInt32 = 1664525
    static let c: UInt32 = 1013904223
    var s: UInt32
    
    init(s: UInt32) {
        self.s = s
    }
    
    func next32() -> UInt32 {
        self.s = (LinearCongruentialGenerator.a &* s) &+ LinearCongruentialGenerator.c
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

extension Array {
    func shuffled(rng: RandomIntegerGenerator) -> [Element] {
        // Fischer-Yates shuffle
        var result = [Element]()
        guard self.count > 0 else { return result }
        var indicies = (0...self.count-1).map({ return $0 })
        while indicies.count > 0 {
            let i = rng.nextInt(exclusiveUpperBound: indicies.count)
            let idx = indicies.remove(at: i)
            result.append(self[idx])
        }
        return result
    }
    
    func takeRandom(n: Int, rng: RandomIntegerGenerator) -> [Element] {
        // Fischer-Yates that ends early
        var result = [Element]()
        guard self.count > 0 else { return result }
        var indicies = (0...self.count-1).map({ return $0 })
        while indicies.count > 0 && result.count < n {
            let i = rng.nextInt(exclusiveUpperBound: indicies.count)
            let idx = indicies.remove(at: i)
            result.append(self[idx])
        }
        return result
    }
}

extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }
    
    func consistentHash() -> UInt64 {
       var result = UInt64 (5381)
       let buf = [UInt8](self.utf8)
       for b in buf {
           result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
       }
       return result
    }

}
