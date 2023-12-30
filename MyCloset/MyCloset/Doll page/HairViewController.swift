//
//  HairViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

import Foundation
import UIKit

class HairViewController: BaseTopsViewController {
    override func setupClothes() {
        outfitss = [neckline, sleeve]
        outfits = outfitss?[0]
        selected = [neckline[0], sleeve[0]]
        drawIndex = 5
        colorChosenIndex = 2
    }
    
    override func setupDollEachPart() {
        cellYPos = 20
        codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44),
            buttonTitle: ["瀏海","髮型","顏色"])
        neckline = [
            DollCloth(outer: "瀏海1", bottom: "B瀏海1", name: "neckline"),
            DollCloth(outer: "瀏海2", bottom: "B瀏海2", name: "neckline"),
            DollCloth(outer: "瀏海3", bottom: "B瀏海3", name: "neckline"),
            DollCloth(outer: "瀏海4", bottom: "B瀏海4", name: "neckline"),
            DollCloth(outer: "瀏海5", bottom: "B瀏海5", name: "neckline"),
            DollCloth(outer: "瀏海6", bottom: "B瀏海6", name: "neckline"),
            DollCloth(outer: "瀏海7", bottom: "B瀏海7", name: "neckline"),
            DollCloth(outer: "瀏海8", bottom: "B瀏海8", name: "neckline"),
            DollCloth(outer: "瀏海9", bottom: "B瀏海9", name: "neckline")
        ]
        sleeve = [
            DollCloth(outer: "頭髮1", bottom: "B頭髮1", name: "sleeve"),
            DollCloth(outer: "頭髮2", bottom: "B頭髮2", name: "sleeve"),
            DollCloth(outer: "頭髮3", bottom: "B頭髮3", name: "sleeve"),
            DollCloth(outer: "頭髮4", bottom: "B頭髮4", name: "sleeve"),
            DollCloth(outer: "頭髮5", bottom: "B頭髮5", name: "sleeve"),
            DollCloth(outer: "頭髮6", bottom: "B頭髮6", name: "sleeve"),
            DollCloth(outer: "頭髮7", bottom: "B頭髮7", name: "sleeve"),
            DollCloth(outer: "頭髮8", bottom: "B頭髮8", name: "sleeve"),
            DollCloth(outer: "頭髮9", bottom: "B頭髮9", name: "sleeve")
        ]
        imageViewDoll.image = UIImage(named: "無")
        setupDollPart(imageView: &dollParts["Bdoll"], imageName: "娃娃2B", tintColor: nil)
        setupDollPart(imageView: &dollParts["doll"], imageName: "娃娃2", tintColor: nil)
        
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: neckline[0].bottom, tintColor: selectedColor)
        
        setupDollPart(imageView: &dollParts["neckline"], imageName: neckline[0].outer, tintColor: nil)

        setupDollPart(imageView: &dollParts["sleeve"], imageName: sleeve[0].outer, tintColor: nil)
        if let imageView = dollParts["sleeve"] {
            imageView.superview?.sendSubviewToBack(imageView)
        }
        
        setupDollPart(imageView: &dollParts["Bsleeve"], imageName: sleeve[0].bottom, tintColor: selectedColor)
        if let imageView = dollParts["Bsleeve"] {
            imageView.superview?.sendSubviewToBack(imageView)
        }
    }
    
    override func changeClothName(with cloth: DollCloth) {
        switch cloth.name {
        case "neckline": selected?[0] = cloth
        case "sleeve": selected?[1] = cloth
        default: break
        }
    }
    
    override func addButtonTapped() {
        print("add")
        var cloth: [String] = []
        var clothB: [String] = []
        for select in selected! {
            cloth.append(select.outer)
            clothB.append(select.bottom)
        }
        print(cloth, clothB)
        let color = selectedColor
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        print(red, green, blue)
        print(cloth)
        print(clothB)
        CoreDataManager.shared.addHair(hair: cloth, hairB: clothB, color: [red, green, blue])
        delegate?.hairToChangeCloth()
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is ChangeClothesViewController {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
}
