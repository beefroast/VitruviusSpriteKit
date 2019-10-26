//
//  SelectCharacterViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 26/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SpriteKit

class SelectCharacterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - UITableViewDelegate/DataSource Implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CharacterClass.asList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TavernViewControllerTableViewCell else { return UITableViewCell() }
        
        switch CharacterClass.asList()[indexPath.row] {
            
        case .swashbucker:
            cell.lblHeader?.text = "Swashbuckler"
            cell.lblSubtitle?.text = "TODO"
            
        case .barbarian:
            cell.lblHeader?.text = "Barbarian"
            cell.lblSubtitle?.text = "TODO"
            
        case .priest:
            cell.lblHeader?.text = "Priest"
            cell.lblSubtitle?.text = "TODO"
            
        case .wizard:
            cell.lblHeader?.text = "Wizard"
            cell.lblSubtitle?.text = "Pick this one it's actually playable"
            
        case .scoundrel:
            cell.lblHeader?.text = "Scoundrel"
            cell.lblSubtitle?.text = "TODO"
            
        case .monk:
            cell.lblHeader?.text = "Monk"
            cell.lblSubtitle?.text = "TODO"
            
        case .thief:
            cell.lblHeader?.text = "Thief"
            cell.lblSubtitle?.text = "TODO"
            
        case .paladin:
            cell.lblHeader?.text = "Paladin"
            cell.lblSubtitle?.text = "TODO"
            
        case .spellsword:
            cell.lblHeader?.text = "Spellsword"
            cell.lblSubtitle?.text = "TODO"
            
        case .sage:
            cell.lblHeader?.text = "Sage"
            cell.lblSubtitle?.text = "TODO"
            
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedClass = CharacterClass.asList()[indexPath.row]
        let state = GameState.newGameWith(name: "Benji", characterClass: selectedClass)
        
        // Make a town VC
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "town") as! TownViewController
        
        vc.gameState = state
        
        SKTexture.preload([
            SKTexture(imageNamed: "crab"),
            SKTexture(imageNamed: "archery_yard"),
            SKTexture(imageNamed: "fireball"),
            SKTexture(imageNamed: "mana_storm"),
            SKTexture(imageNamed: "placeholder"),
        ]) {
            DispatchQueue.main.async {
                self.navigationController?.setViewControllers([vc], animated: false)
            }
        }
    }
    

}
