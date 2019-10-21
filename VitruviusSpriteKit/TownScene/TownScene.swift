//
//  TownScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 20/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit


class GameState: Codable {
    var playerData: PlayerData
    var buildings: [Building]
    var daysUntilNextBoss: Int
    
    init(playerData: PlayerData, buildings: [Building], daysUntilNextBoss: Int) {
        self.playerData = playerData
        self.buildings = buildings
        self.daysUntilNextBoss = daysUntilNextBoss
    }
}


protocol TownSceneDelegate: AnyObject {
    func town(scene: TownScene, selectedBuildBuilding: Any?)
}


class TownScene: SKScene, DialogBoxNodeDelegate, BuildingNodeDelegate {

    var gameState: GameState
    var playerBedroom: BuildingNode?
    var dialogBox: DialogBoxNode?
    weak var townSceneDelegate: TownSceneDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        
        self.gameState = GameState.init(
            playerData: PlayerData.newPlayerFor(name: "Benji", characterClass: .wizard),
            buildings: [],
            daysUntilNextBoss: 30
        )
        
        super.init(coder: aDecoder)
        
        self.playerBedroom = self.getFirstChildRecursive(fn: { (node) -> Bool in
            (node as? BuildingNode) != nil
        }).flatMap({ $0 as? BuildingNode })
        self.playerBedroom?.delegate = self
        self.playerBedroom?.isUserInteractionEnabled = true
        
        self.dialogBox = self.childNode(withName: "dialog") as? DialogBoxNode
        self.dialogBox?.delegate = self
        self.dialogBox?.isUserInteractionEnabled = true
    }
    
    func addBuilding(building: Building) -> Void {
        
        self.gameState.buildings.append(building)
        self.gameState.playerData.currentGold -= building.type.cost
        let buildingNode = BuildingNode.newInstance(building: building, delegate: self)
        self.addChild(buildingNode)
        buildingNode.position = CGPoint.init(x: 200, y: 0)
        buildingNode.size = CGSize.init(width: 100, height: 100)
        buildingNode.isUserInteractionEnabled = true
    }
    
    // MARK: - BuildingNodeDelegate Implementation
    
    func onPressed(sender: BuildingNode) {
        self.townSceneDelegate?.town(scene: self, selectedBuildBuilding: sender)
        
//        self.dialogBox?.run(SKAction.fadeIn(withDuration: 0.2), completion: {
//            self.dialogBox?.isUserInteractionEnabled = true
//        })
    }
    
    // MARK: - DialogBoxNodeDelegate Implementation
    
    func onDialogSubmitted(dialog: DialogBoxNode) {
        
        self.run(SKAction.fadeOut(withDuration: 0.2)) {
            dialog.alpha = 0.0
            dialog.isUserInteractionEnabled = false
            self.gameState.daysUntilNextBoss -= 1
            self.gameState.playerData.currentHp = min(self.gameState.playerData.currentHp + 20, self.gameState.playerData.maxHp)
            self.run(SKAction.fadeIn(withDuration: 0.2)) {
                
            }
        }
    }
    
    func onDialogCancelled(dialog: DialogBoxNode) {
        dialog.run(SKAction.fadeOut(withDuration: 0.2)) {
            dialog.isUserInteractionEnabled = false
        }
    }
    
}

protocol BuildingNodeDelegate: AnyObject {
    func onPressed(sender: BuildingNode)
}

class BuildingNode: SKSpriteNode {
    
    weak var delegate: BuildingNodeDelegate? = nil
    var building: Building? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.onPressed(sender: self)
    }
    
    static func newInstance(building: Building, delegate: BuildingNodeDelegate) -> BuildingNode {
        // TODO: Make this so it creates everything we need to display a building
        let node = BuildingNode(imageNamed: "Highlander's_hut")
        node.delegate = delegate
        node.building = building
        return node
    }
}

protocol HomeOverlayNodeDelegate: AnyObject {
    func homeOverlayNodeChoseRest(sender: HomeOverlayNode)
    func homeOverlayNodeCancelled(sender: HomeOverlayNode)
}

class HomeOverlayNode: SKNode {
    
    weak var delegate: HomeOverlayNodeDelegate? = nil
    
    
}


protocol DialogBoxNodeDelegate: AnyObject {
    func onDialogCancelled(dialog: DialogBoxNode)
    func onDialogSubmitted(dialog: DialogBoxNode)
}

class DialogBoxNode: SKSpriteNode, ButtonNodeDelegate {
    
    weak var delegate: DialogBoxNodeDelegate? = nil
    
    var titleNode: SKLabelNode?
    var textNode: SKLabelNode?
    var cancelButton: ButtonNode?
    var submitButton: ButtonNode?
    
    override var isUserInteractionEnabled: Bool {
        get { return super.isUserInteractionEnabled }
        set (x) {
            super.isUserInteractionEnabled = x
            self.cancelButton?.isUserInteractionEnabled = true
            self.submitButton?.isUserInteractionEnabled = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.getNodeReferences()
    }
    
    func getNodeReferences() {
        self.titleNode = self.childNode(withName: "title") as? SKLabelNode
        self.textNode = self.childNode(withName: "text") as? SKLabelNode
        self.cancelButton = self.childNode(withName: "cancel") as? ButtonNode
        self.submitButton = self.childNode(withName: "submit") as? ButtonNode
        self.cancelButton?.delegate = self
        self.submitButton?.delegate = self
    }
    
    func onPressed(sender: ButtonNode) {
        switch sender {
        case self.cancelButton: self.delegate?.onDialogCancelled(dialog: self)
        case self.submitButton: self.delegate?.onDialogSubmitted(dialog: self)
        default: break
        }
    }
}

protocol ButtonNodeDelegate: AnyObject {
    func onPressed(sender: ButtonNode)
}

class ButtonNode: SKSpriteNode {
    
    var buttonTitle: SKLabelNode? = nil
    weak var delegate: ButtonNodeDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buttonTitle = self.childNode(withName: "title") as? SKLabelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.onPressed(sender: self)
    }
}
