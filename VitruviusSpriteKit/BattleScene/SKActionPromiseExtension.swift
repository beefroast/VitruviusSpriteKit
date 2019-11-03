//
//  SKActionPromiseExtension.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 3/11/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit
import SpriteKit

extension SKNode {
    
    
    func runActionPromise(action: SKAction) -> Promise<SKNode> {
        return Promise { seal in
            self.run(action) {
                seal.fulfill(self)
            }
        }
    }
}
