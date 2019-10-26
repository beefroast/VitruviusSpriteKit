//
//  TownScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 20/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import CollectionNode



protocol TownSceneDelegate: AnyObject {
    func town(scene: TownScene, selectedBuildBuilding: Any?)
}


class TownScene: SKScene, DialogBoxNodeDelegate, BuildingNodeDelegate, CollectionNodeDataSource, CollectionNodeDelegate, TavernViewControllerDelegate {

    weak var viewController: UIViewController? = nil
    
    private var updatables: [IUpdatable] = []
    private var collectionNode: CollectionNode!
    private var buildingNodes: [BuildingNode]!
    var gameState: GameState!
    
    weak var townSceneDelegate: TownSceneDelegate? = nil
    var buildingParentNode: BuildingParentNode? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setGameState(gameState: GameState) -> Void {
        self.gameState = gameState
        self.buildingNodes = self.gameState.buildings.map({ (building) -> BuildingNode in
            return BuildingNode.newInstance(building: building, delegate: nil)
        })
    }
    
    func addBuilding(building: Building) -> Void {
        self.gameState.buildings.append(building)
        self.gameState.playerData.currentGold -= building.type.cost
        let buildingNode = BuildingNode.newInstance(building: building, delegate: self)
        self.buildingNodes.append(buildingNode)
        self.collectionNode.reloadData()
    }
    
    override func didMove(to view: SKView) {
        
        collectionNode = CollectionNode(at: view)
        collectionNode.spaceBetweenItems = 40

        collectionNode.dataSource = self
        collectionNode.delegate = self

        self.updatables.append(collectionNode)
        
        addChild(collectionNode)
        
        self.collectionNode(collectionNode, didShowItemAt: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.updatables.forEach { (updatable) in
            updatable.updateNode(currentTime: currentTime)
        }
    }
    
    func didSelectBuildingNode(buildingNode: BuildingNode) -> Void {
        
        if let type = buildingNode.building?.type as? BTTavern {
            self.viewController?.performSegue(withIdentifier: "tavern", sender: self)
        
        } else if let type = buildingNode.building?.type as? BTJoinery {
            self.townSceneDelegate?.town(scene: self, selectedBuildBuilding: self)
        
        } else if let type = buildingNode.building?.type as? BTForge {
            // Allow the user to pick a card to upgrade
            
        }
    }
    
    // MARK: - CollectionNodeDataSource, CollectionNodeDelegate Implementation
    
    func numberOfItems() -> Int {
        return self.gameState.buildings.count
    }

    func collectionNode(_ collection: CollectionNode, itemFor index: Index) -> CollectionNodeItem {
        
        let collectionNodeItem = CollectionNodeItem()
        
        let node = self.buildingNodes[index]
        
        node.removeFromParent()
        collectionNodeItem.addChild(node)

        return collectionNodeItem
    }
    
    var lastSelectedIndex: Int? = nil
    
    func collectionNode(_ collectionNode: CollectionNode, didShowItemAt index: Index) {
        
        guard index != lastSelectedIndex else { return }

        let nextNode = self.buildingNodes[index]
        nextNode.run(SKAction.scale(to: 1.5, duration: 0.2))
        nextNode.zPosition = 10

        if let last = lastSelectedIndex {
            let last = self.buildingNodes[last]
            last.run(SKAction.scale(to: 1.2, duration: 0.2))
            last.zPosition = 0
        }

        lastSelectedIndex = index
    }

    func collectionNode(_ collectionNode: CollectionNode, didSelectItem item: CollectionNodeItem, at index: Index) {
        
        if index == lastSelectedIndex {
            self.didSelectBuildingNode(buildingNode: self.buildingNodes[index])
        } else {
            collectionNode.snap(to: index, withDuration: 0.2)
            self.collectionNode(collectionNode, didShowItemAt: index)
        }
    }
    
    
    // MARK: - BuildingNodeDelegate Implementation
    
    func onPressed(sender: BuildingNode) {
        self.townSceneDelegate?.town(scene: self, selectedBuildBuilding: sender)
        
        
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
    
    // MARK: - TavernViewControllerDelegate Implementation
    
    func tavern(viewController: TavernViewController, cancelled: Any?) {
//        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func tavern(viewController: TavernViewController, selectedRest: Any?) {
//        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func tavern(viewController: TavernViewController, selectedMission: Mission) {
//        self.viewController?.dismiss(animated: true, completion: nil)
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
    
    static func newInstance(building: Building, delegate: BuildingNodeDelegate?) -> BuildingNode {
        // TODO: Make this so it creates everything we need to display a building
        let node = BuildingNode(imageNamed: "Highlander's_hut")
        node.size = CGSize(width: 100, height: 100)
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

class BuildingParentNode: SKNode {
    
    func addBuilding(node: BuildingNode) -> Void {
        
        self.addChildPreserveTransform(child: node)
        
        node.resetTransforms()
        
        // Lay out the buildings
        
        for c in self.children.enumerated() {
            c.element.position = CGPoint.init(x: CGFloat(0 + c.offset * 100), y: 0)
        }
    }
}


//class ScrollNode: SKSpriteNode {
//
//    var initialPosition: CGPoint?
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard initialPosition == nil else {
//            return
//        }
//        guard let t = touches.first else {
//            return
//        }
//
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        self.initialPosition
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//    }
//}
