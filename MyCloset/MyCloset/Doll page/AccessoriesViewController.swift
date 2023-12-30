//
//  AccessoriesViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

import Foundation
import UIKit

class AccessoriesViewController: BaseTopsViewController {
    override func setupClothes() {
        outfitss = [neckline]
        outfits = outfitss?[0]
        selected = [neckline[0]]
        drawIndex = 1
        colorChosenIndex = 2
    }
    
    override func setupDollEachPart() {
        cellYPos = 4/3
        codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44),
            buttonTitle: ["飾品","手繪","顏色"])
        neckline = [
            DollCloth(outer: "飾品1", bottom: "B飾品1", name: "neckline"),
            DollCloth(outer: "飾品2", bottom: "B飾品2", name: "neckline"),
            DollCloth(outer: "飾品3", bottom: "B飾品3", name: "neckline"),
            DollCloth(outer: "飾品4", bottom: "B飾品4", name: "neckline"),
            DollCloth(outer: "飾品5", bottom: "B飾品5", name: "neckline"),
            DollCloth(outer: "飾品6", bottom: "B飾品6", name: "neckline"),
            DollCloth(outer: "飾品7", bottom: "B飾品7", name: "neckline"),
            DollCloth(outer: "飾品8", bottom: "B飾品8", name: "neckline"),
            DollCloth(outer: "飾品9", bottom: "B飾品9", name: "neckline"),
            DollCloth(outer: "飾品10", bottom: "B飾品10", name: "neckline"),
            DollCloth(outer: "飾品11", bottom: "B飾品11", name: "neckline"),
            DollCloth(outer: "飾品12", bottom: "B飾品12", name: "neckline"),
            DollCloth(outer: "飾品13", bottom: "B飾品13", name: "neckline"),
            DollCloth(outer: "飾品14", bottom: "B飾品14", name: "neckline")
        ]
        imageViewDoll.image = UIImage(named: "無")
        setupDollPart(imageView: &dollParts["bottom"], imageName: "上衣", tintColor: nil)
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: neckline[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["neckline"], imageName: neckline[0].outer, tintColor: nil)
    }
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OutfitCollectionViewCell.reuseIdentifier,
            for: indexPath) as? OutfitCollectionViewCell {
            if let outfit = outfits?[indexPath.item] {
                cell.configureAcc(with: outfit)
            }
            return cell
        } else {
            let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultCell", for: indexPath)
            return defaultCell
        }
    }
    
    override func changeClothName(with cloth: DollCloth) {
        switch cloth.name {
        case "neckline": selected?[0] = cloth
        default: break
        }
    }
}
