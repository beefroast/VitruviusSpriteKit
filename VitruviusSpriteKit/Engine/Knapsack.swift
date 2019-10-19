//
//  Knapsack.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 19/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class Knapsack {
    
    struct Item<T> {
        let elt: T
        let cost: Int
        let value: Int
        init(elt: T, cost: Int, value: Int) {
            self.elt = elt
            self.cost = cost
            self.value = value
        }
    }
    
    
    static func solve<T>(maxWeight w: Int, items: [Item<T>]) -> [T] {
        
        var val = Array(repeating: Array(repeating: 0, count: items.count), count: w+1)
        
        for i in (0...items.count-1) {
            for mW in (0...w) {
                
                // Try again at next weight if we can't fit this item
                guard items[i].cost <= mW else {
                    guard i > 0 else {
                        continue
                    }
                    val[mW][i] = val[mW][i-1]
                    continue
                }
                
                // If we're on the first row, don't compare to the previous row
                guard i > 0 else {
                    val[mW][i] = items[i].cost
                    continue
                }
                
                // We need to compare taking the current item plus the max
                // of the adjusted weight vs not taking the item
                val[mW][i] = max(val[mW-items[i].cost][i-1] + items[i].value, val[mW][i-1])
            }
        }
        
        // Now we have the maxximum possible value in the last indexx of the array
        print(val[w][items.count-1])
        
        // Work backwards to work out which items we've selected
        var weightRemaining = w
        var selectedItems: [Item<T>] = []
        
        for i in (0...items.count-1).reversed() {
            
            guard i > 0 else {
                // We picked the first item if it's non-zero here
                if val[weightRemaining][i] != 0 {
                    selectedItems.append(items[i])
                }
                break
            }
            
            guard items[i].cost <= weightRemaining else {
                // We didn't pick this item
                continue
            }
            
            guard val[weightRemaining][i] != val[weightRemaining][i-1] else {
                // We didn't pick this item
                continue
            }
            
            // We did pick this item
            selectedItems.append(items[i])
            weightRemaining -= items[i].cost
        }
        
        
        
        
        return selectedItems.map({ $0.elt })
    }
}
