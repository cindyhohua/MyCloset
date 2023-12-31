//
//  MyProfileViewController2.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/25.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class MyProfileViewController: ProfileViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        mySetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseStorageManager.shared.getAuth { author in
            self.author = author
        }
    }

    func mySetup() {
        let setButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"), style: .plain,
            target: self, action: #selector(setButtonTapped))
        setButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = setButton
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"), style: .plain,
            target: self, action: #selector(savedButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Profile"
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
         NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }

    @objc func setButtonTapped() {
        let secondViewController = EditProfileView()
        secondViewController.bindViewModel()
        secondViewController.viewModel.author = self.author
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func savedButtonTapped() {
        let secondViewController = SavedViewController()
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
