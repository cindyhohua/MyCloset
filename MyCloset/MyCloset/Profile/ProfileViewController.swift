//
//  ProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try Auth.auth().signOut()
            // Successful sign-out
            print("Sign-out successful.")
        } catch let signOutError as NSError {
            // Handle sign-out error
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
