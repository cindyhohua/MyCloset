//
//  MineDollChooseViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/11.
//

import UIKit

protocol MineDollToPost: AnyObject {
    func mineDollToPost(dollImageData: Data)
}

class MineDollChooseViewController: MineDollViewController {
    var delegate: MineDollToPost?
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myWearing = self.mineDoll?[indexPath.row].myWearing {
            delegate?.mineDollToPost(dollImageData: myWearing)
            dismiss(animated: true)
        }
    }
}
