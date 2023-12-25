//
//  OthersProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/22.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class OthersProfileViewController: ProfileViewController {
    private var followButton = UIBarButtonItem()
    private var blockButton = UIBarButtonItem()
    private var backButton = UIBarButtonItem()
    private let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    private let currentUser = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        othersSetup()
    }
    
    func othersSetup() {
        blockButton = UIBarButtonItem(
            image: UIImage(systemName: "exclamationmark.triangle"),
            style: .plain, target: self, action: #selector(blockButtonTapped))
        blockButton.tintColor = .lightBrown()
        
        followButton.tintColor = .lightBrown()
        self.navigationItem.rightBarButtonItem = followButton
        followButton.target = self
        followButton.action = followButton.action
        
        backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"), style: .plain,
            target: self, action: #selector(backButtonTapped))
        backButton.tintColor = UIColor.lightBrown()
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
         NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        
        if author?.id == currentUser {
            followButton.isEnabled = false
            navigationItem.leftBarButtonItem = backButton
            followButton.tintColor = .clear
        } else {
            if author?.followers?.contains(Auth.auth().currentUser?.uid ?? "qq") == true {
                followButton.title = "Following"
                followButton.isEnabled = true
                followButton.action = #selector(unfollowButtonTapped)
            } else if author?.pending?.contains(Auth.auth().currentUser?.uid ?? "qq") == true {
                followButton.title = "Requesting"
                followButton.isEnabled = true
                followButton.action = #selector(unrequestButtonTapped)
            } else {
                followButton.title = "Follow"
                print("now is follow button")
                followButton.isEnabled = true
                followButton.action = #selector(followButtonTapped)
            }
            navigationItem.leftBarButtonItems = [backButton, blockButton]
        }
    }
    
    @objc func blockButtonTapped() {
        FirebaseStorageManager.shared.getAuth { myProfile in
            if (myProfile.blockedUsers?.contains(self.author?.id ?? "")) != nil {
                let alertController = UIAlertController(
                    title: "Confirm unblock",
                    message: "Are you sure you want to unblock this user?",
                    preferredStyle: .alert
                )
                alertController.addAction(self.cancelAction)
                
                let unblockAction = UIAlertAction(title: "unlock", style: .destructive) { _ in
                    FirebaseStorageManager.shared.unblockOther(authorId: self.author?.id ?? "") { result in
                        switch result {
                        case .success:
                            print("User unblocked successfully.")
                            guard let viewControllers = self.navigationController?.viewControllers else { return }
                            for controller in viewControllers {
                                if controller is HomePageViewController {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                }
                                if controller is MyProfileViewController {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                }
                            }
                        case .failure(let error):
                            print("Error unblocking user: \(error.localizedDescription)")
                        }
                    }
                }
                alertController.addAction(unblockAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(
                    title: "Confirm Block",
                    message: "Are you sure you want to block this user?",
                    preferredStyle: .alert
                )
                alertController.addAction(self.cancelAction)
                
                let blockAction = UIAlertAction(title: "Block", style: .destructive) { _ in
                    FirebaseStorageManager.shared.blockOther(authorId: self.author?.id ?? "") { result in
                        switch result {
                        case .success:
                            print("User blocked successfully.")
                            guard let viewControllers = self.navigationController?.viewControllers else { return }
                            for controller in viewControllers {
                                if controller is HomePageViewController {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                }
                                if controller is MyProfileViewController {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                }
                            }
                        case .failure(let error):
                            print("Error blocking user: \(error.localizedDescription)")
                        }
                    }
                }
                alertController.addAction(blockAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    @objc func followButtonTapped() {
        FirebaseStorageManager.shared.sendFriendRequest(toUserID: author?.id ?? "") { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                self.followButton.title = "Requesting"
                self.followButton.action = #selector(self.unrequestButtonTapped)
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
                print("Friend request sent successfully")
            }
        }
    }
    
    @objc func unfollowButtonTapped() {
        let alertController = UIAlertController(
            title: "Unfollow", message: "Are you sure you want to unfollow?",
            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.performUnfollow()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(self.cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func performUnfollow() {
        FirebaseStorageManager.shared.removeFriend(friendID: author?.id ?? "") { error in
            if let error = error {
                print("Error removing friend: \(error)")
            } else {
                self.followButton = UIBarButtonItem(
                    title: "Follow", style: .plain,
                    target: self, action: #selector(self.followButtonTapped))
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
            }
        }
    }
    
    @objc func unrequestButtonTapped() {
        FirebaseStorageManager.shared.cancelFriendRequest(toUserID: author?.id ?? "") { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                self.followButton = UIBarButtonItem(
                    title: "Follow", style: .plain,
                    target: self, action: #selector(self.followButtonTapped))
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
            }
        }
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
