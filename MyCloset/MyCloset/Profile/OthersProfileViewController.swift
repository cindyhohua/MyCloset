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
        navigationItem.rightBarButtonItem = followButton
    }
    
    func othersSetup() {
        configureNavigationBarButtons()
        updateFollowButtonState()
    }

    private func configureNavigationBarButtons() {
        backButton = createBarButtonItem(with: "chevron.backward.circle", action: #selector(backButtonTapped))
        blockButton = createBarButtonItem(with: "exclamationmark.triangle", action: #selector(blockButtonTapped))

        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)
        ]

        if author?.id == currentUser {
            followButton.isEnabled = false
            followButton.tintColor = .clear
            navigationItem.leftBarButtonItem = backButton
        } else {
            navigationItem.leftBarButtonItems = [backButton, blockButton]
        }
    }

    private func updateFollowButtonState() {
        followButton.tintColor = .lightBrown()
        followButton.target = self
        let currentUserID = Auth.auth().currentUser?.uid ?? "qq"

        switch (author?.followers?.contains(currentUserID), author?.pending?.contains(currentUserID)) {
        case (true, _):
            setFollowButton(title: "Following", action: #selector(unfollowButtonTapped))
        case (_, true):
            setFollowButton(title: "Requesting", action: #selector(unrequestButtonTapped))
        default:
            setFollowButton(title: "Follow", action: #selector(followButtonTapped))
        }
    }

    private func setFollowButton(title: String, action: Selector) {
        followButton.title = title
        followButton.isEnabled = true
        followButton.action = action
    }

    private func createBarButtonItem(with systemName: String, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            image: UIImage(systemName: systemName),
            style: .plain,
            target: self,
            action: action
        )
        button.tintColor = UIColor.lightBrown()
        return button
    }

    @objc func blockButtonTapped() {
        FirebaseStorageManager.shared.getAuth { [weak self] myProfile in
            guard let self = self, let authorId = self.author?.id else { return }

            let isUserBlocked = myProfile.blockedUsers?.contains(authorId) ?? false
            let title = isUserBlocked ? "Confirm Unblock" : "Confirm Block"
            let message = isUserBlocked ?
            "Are you sure you want to unblock this user?" : "Are you sure you want to block this user?"
            let actionTitle = isUserBlocked ? "Unblock" : "Block"

            self.showAlertForBlocking(
                title: title, message: message,
                actionTitle: actionTitle,
                isBlocking: !isUserBlocked, authorId: authorId)
        }
    }

    private func showAlertForBlocking(
        title: String, message: String, actionTitle: String,
        isBlocking: Bool, authorId: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(cancelAction)

        let action = UIAlertAction(title: actionTitle, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let operation = isBlocking ?
            FirebaseStorageManager.shared.blockOther : FirebaseStorageManager.shared.unblockOther

            operation(authorId) { result in
                switch result {
                case .success:
                    print("Operation successful.")
                    self.popToRelevantViewController()
                case .failure(let error):
                    print("Error during operation: \(error.localizedDescription)")
                }
            }
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    private func popToRelevantViewController() {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is HomePageViewController || controller is MyProfileViewController {
                self.navigationController?.popToViewController(controller, animated: true)
                return
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
