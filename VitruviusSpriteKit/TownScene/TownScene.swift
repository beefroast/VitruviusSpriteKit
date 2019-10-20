//
//  TownScene.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 20/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit



class TownScene: SKScene, DialogBoxNodeDelegate, BuildingNodeDelegate {

    var playerBedroom: BuildingNode?
    var dialogBox: DialogBoxNode?
    
    required init?(coder aDecoder: NSCoder) {
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
    
    // MARK: - BuildingNodeDelegate Implementation
    
    func onPressed(sender: BuildingNode) {
        self.dialogBox?.run(SKAction.fadeIn(withDuration: 0.2), completion: {
            self.dialogBox?.isUserInteractionEnabled = true
        })
    }
    
    // MARK: - DialogBoxNodeDelegate Implementation
    
    func onDialogSubmitted(dialog: DialogBoxNode) {
        dialog.run(SKAction.fadeOut(withDuration: 0.2)) {
            dialog.isUserInteractionEnabled = false
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.onPressed(sender: self)
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
