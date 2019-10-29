//
//  TavernViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 25/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit



protocol TavernViewControllerDelegate: AnyObject {
    func tavern(viewController: TavernViewController, selectedRest: Any?)
    func tavern(viewController: TavernViewController, selectedMission: Mission)
    func tavern(viewController: TavernViewController, cancelled: Any?)
}

class TavernViewControllerTableViewCell: UITableViewCell {
    @IBOutlet var lblHeader: UILabel?
    @IBOutlet var lblSubtitle: UILabel?
}

class TavernViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    weak var delegate: TavernViewControllerDelegate? = nil
    
    @IBOutlet var tableView: UITableView?
    
    var availableMissions: [Mission] = [] {
        didSet { self.tableView?.reloadData() }
    }
    
    override func viewDidLoad() {
        self.availableMissions = [
            Mission.init(
                challengeRatingModifier: 1,
                remainingEncounters: 2
            ),
            Mission.init(
                challengeRatingModifier: 4,
                remainingEncounters: 1
            ),
            Mission.init(
                challengeRatingModifier: 0,
                remainingEncounters: 5
            )
        ]
    }

    // MARK: - UITableViewDelegate/DataSource Implementation
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + self.availableMissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TavernViewControllerTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
            
        case 0:
            cell.lblHeader?.text = "Sleep"
            cell.lblSubtitle?.text = "Sleeping restores 20hp but costs you a day."
            
        case self.availableMissions.count + 1:
            cell.lblHeader?.text = "Exit Tavern"
            cell.lblSubtitle?.text = "Thanks for visiting."
            
        default:
            let mission = availableMissions[indexPath.row - 1]
            cell.lblHeader?.text = mission.placeholderName()
            cell.lblSubtitle?.text = "Will take \(mission.calculateMissionDuration(travelTime: 4)) days."
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        
        case 0:
            self.delegate?.tavern(viewController: self, selectedRest: nil)
            
        case self.availableMissions.count + 1:
            self.delegate?.tavern(viewController: self, cancelled: nil)
            
        default:
            let mission = availableMissions[indexPath.row - 1]
            self.delegate?.tavern(viewController: self, selectedMission: mission)
        }
    }
    
    
}
