//
//  SavedViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/29.
//

import UIKit
import SnapKit

class SavedViewController: BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        FirebaseStorageManager.shared.getAuth { author in
            self.savedPost = author.saved
        }
        navigationItem.title = "Saved"
    }
}
