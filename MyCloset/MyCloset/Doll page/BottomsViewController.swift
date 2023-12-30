//
//  BottomsViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/30.
//

import UIKit

class BottomsViewController: BaseTopsViewController {

    override func setupClothes() {
        outfitss = [neckline, sleeve]
        outfits = outfitss?[0]
        selected = [neckline[0], sleeve[0]]
        drawIndex = 2
        colorChosenIndex = 3
    }
    
    override func setupDollEachPart() {
        cellYPos = 4/3
        codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44),
            buttonTitle: ["褲頭", "褲子", "手繪", "顏色"])
        neckline = [
            DollCloth(outer: "褲頭1", bottom: "B褲頭1", name: "neckline"),
            DollCloth(outer: "褲頭2", bottom: "B褲頭2", name: "neckline"),
            DollCloth(outer: "褲頭3", bottom: "B褲頭3", name: "neckline"),
            DollCloth(outer: "褲頭4", bottom: "B褲頭4", name: "neckline")
        ]
        sleeve = [
            DollCloth(outer: "褲子1", bottom: "B褲子1", name: "sleeve"),
            DollCloth(outer: "褲子2", bottom: "B褲子2", name: "sleeve"),
            DollCloth(outer: "褲子3", bottom: "B褲子3", name: "sleeve"),
            DollCloth(outer: "褲子4", bottom: "B褲子4", name: "sleeve"),
            DollCloth(outer: "褲子5", bottom: "B褲子5", name: "sleeve"),
            DollCloth(outer: "褲子6", bottom: "B褲子6", name: "sleeve"),
            DollCloth(outer: "褲子7", bottom: "B褲子7", name: "sleeve"),
            DollCloth(outer: "褲子8", bottom: "B褲子8", name: "sleeve"),
            DollCloth(outer: "褲子9", bottom: "B褲子9", name: "sleeve"),
            DollCloth(outer: "褲子10", bottom: "B褲子10", name: "sleeve"),
            DollCloth(outer: "褲子11", bottom: "B褲子11", name: "sleeve"),
            DollCloth(outer: "褲子12", bottom: "B褲子12", name: "sleeve"),
            DollCloth(outer: "褲子13", bottom: "B褲子13", name: "sleeve"),
            DollCloth(outer: "褲子14", bottom: "B褲子14", name: "sleeve"),
            DollCloth(outer: "褲子15", bottom: "B褲子15", name: "sleeve"),
            DollCloth(outer: "褲子16", bottom: "B褲子16", name: "sleeve")
        ]
        setupDollPart(imageView: &dollParts["bottom"], imageName: "上衣", tintColor: nil)
        setupDollPart(imageView: &dollParts["Bsleeve"], imageName: sleeve[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["Bneckline"], imageName: neckline[0].bottom, tintColor: selectedColor)
        setupDollPart(imageView: &dollParts["sleeve"], imageName: sleeve[0].outer, tintColor: nil)
        setupDollPart(imageView: &dollParts["neckline"], imageName: neckline[0].outer, tintColor: nil)
    }
    
    override func changeClothName(with cloth: DollCloth) {
        switch cloth.name {
        case "neckline": selected?[0] = cloth
        case "sleeve": selected?[1] = cloth
        default: break
        }
    }
}
