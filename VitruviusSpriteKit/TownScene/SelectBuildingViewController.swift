//
//  SelectBuildingViewController.swift
//  VitruviusSpriteKit
//
//  Created by Benjamin Frost on 20/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit






protocol SelectBuildingViewControllerDelegate: AnyObject {
    func selectBuilding(vc: SelectBuildingViewController, selectedBuilding: BuildingType)
    func selectBuilding(vc: SelectBuildingViewController, cancelled: Any?)
}

class SelectBuildingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
}

class SelectBuildingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var buildingTypes: [BuildingType]? = nil {
        didSet { self.collectionView?.reloadData() }
    }
    
    weak var delegate: SelectBuildingViewControllerDelegate? = nil
    @IBOutlet weak var collectionView: UICollectionView?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.buildingTypes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SelectBuildingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let buildingType = self.buildingTypes?[indexPath.row] else {
            return cell
        }
        
        cell.lblName.text = buildingType.name
        cell.lblCost.text = "\(buildingType.cost)gp"
        cell.lblDescription.text = buildingType.description
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let buildingType = self.buildingTypes?[indexPath.row] else {
            return
        }
        
        self.delegate?.selectBuilding(vc: self, selectedBuilding: buildingType)
    }
}
