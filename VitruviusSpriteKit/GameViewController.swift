//
//  GameViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 3/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


// TODO: Move this into a scene

class GameViewController: UIViewController, TownSceneDelegate, SelectBuildingViewControllerDelegate {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view.subviews.first { (view) -> Bool in
            view as? SKView != nil
        } as! SKView
  
//        let scene = getBattleScene()
        
        let scene = SKScene(fileNamed: "TownScene") as! TownScene
        scene.scaleMode = .aspectFit
        scene.townSceneDelegate = self
        
        // Present the scene
        view.ignoresSiblingOrder = false
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
        view.presentScene(scene)

    }
    
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectBuildingViewController {
            vc.delegate = self
            vc.buildingTypes = [
                BTTavern(),
                BTForge()
            ]
        }
    }
    
    // MARK: - SelectBuildingViewControllerDelegate Implementation
    
    func selectBuilding(vc: SelectBuildingViewController, selectedBuilding: BuildingType) {
        
        // Make a new building of that type
        let building = selectedBuilding.newInstance()
        
        guard let townScene = (self.view as? SKView)?.scene as? TownScene else {
            return
        }
        
        townScene.addBuilding(building: building)
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectBuilding(vc: SelectBuildingViewController, cancelled: Any?) {
        
    }

    // MARK: - TownSceneDelegate Implementation
    
    func town(scene: TownScene, selectedBuildBuilding: Any?) {
        self.performSegue(withIdentifier: "build", sender: selectedBuildBuilding)
    }
}


extension SKNode {
    
    func getFirstChild<Type>() -> Type? {
        self.getFirstChildRecursive { (node) -> Bool in
            (node as? Type) != nil
        }.flatMap { (node) -> Type? in
            node as? Type
        }
    }

    
    
    func getFirstChildRecursive(fn: (SKNode) -> Bool) -> SKNode? {
        
        if fn(self) {
            return self
        
        } else {
            for c in self.children {
                if let found =  c.getFirstChildRecursive(fn: fn) {
                    return found
                }
            }
            return nil
        }
    }
    
    func getGlobalPosition() -> CGPoint {
        guard let parent = self.parent, let scene = self.scene else {
            return CGPoint.zero
        }
        return scene.convert(self.position, from: parent)
    }
    
    func getGlobalZPosition() -> CGFloat {
        return self.zPosition + (self.parent?.getGlobalZPosition() ?? 0.0)
    }
    
    func setGlobalZPosition(z: CGFloat) -> Void {
        self.zPosition = z - (self.parent?.getGlobalZPosition() ?? 0.0)
    }
    
    func getGlobalRotation() -> CGFloat {
        return self.zRotation + (self.parent?.getGlobalRotation() ?? 0.0)
    }
    
    func setGlobalRotation(z: CGFloat) {
        self.zRotation = z - (self.parent?.getGlobalRotation() ?? 0.0)
    }
    
    func getGlobalXScale() -> CGFloat {
        return self.xScale * (self.parent?.getGlobalXScale() ?? 1.0)
    }
    
    func setGlobalXScale(x: CGFloat) -> Void {
        self.xScale = x / (self.parent?.getGlobalXScale() ?? 1.0)
    }
    
    func getGlobalYScale() -> CGFloat {
        return self.yScale * (self.parent?.getGlobalYScale() ?? 1.0)
    }
    
    func setGlobalYScale(y: CGFloat) -> Void {
        self.yScale = y / (self.parent?.getGlobalYScale() ?? 1.0)
    }
    
    
    func addChildPreserveTransform(child: SKNode) -> Void {
        
        if child.parent === self {
            return
        }
        
        guard let parent = child.parent else {
            self.addChild(child)
            return
        }
        
        let globalPosition = child.scene!.convert(child.position, from: parent)
        let globalRotation = child.getGlobalRotation()
        let globalXScale = child.getGlobalXScale()
        let globalYScale = child.getGlobalYScale()
        let globalZ = child.getGlobalZPosition()
        
        child.removeFromParent()
        self.addChild(child)
        
        // TODO: Position
        
        child.position = child.scene!.convert(globalPosition, to: self)
        child.setGlobalRotation(z: globalRotation)
        child.setGlobalXScale(x: globalXScale)
        child.setGlobalYScale(y: globalYScale)
        child.setGlobalZPosition(z: globalZ)
    }

    
}
