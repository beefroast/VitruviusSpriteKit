//
//  AutoSaver.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class AutoSaver {
    
    func writeGameState(gameState: GameState, filename: String = "autosave") throws -> Void {
        let dat = try JSONEncoder().encode(gameState)
        guard var dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: Better error
            throw NSError.init(domain: "Save Error", code: 666, userInfo: nil)
        }
        dir.appendPathComponent(filename)
        try dat.write(to: dir)
        print("Wrote state to '\(dir.absoluteString)'")
    }
    
    func readGameState(gameState: GameState, filename: String = "autosave") throws -> GameState {
        guard var dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: Better error
            throw NSError.init(domain: "Save Error", code: 666, userInfo: nil)
        }
        dir.appendPathComponent(filename)
        let dat = try Data.init(contentsOf: dir)
        return try JSONDecoder().decode(GameState.self, from: dat)
    }
}
