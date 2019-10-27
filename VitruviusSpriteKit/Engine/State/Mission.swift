//
//  Mission.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

class Mission: Codable {
    
    let name: String
    var encounters: [Encounter]
    
    init(name: String, encounters: [Encounter]) {
        self.name = name
        self.encounters = encounters
    }
    
    func isFinished() -> Bool {
        return encounters.count == 0
    }
    
    func getNextEncounter() -> Encounter {
        return self.encounters.removeFirst()
    }
    
}

