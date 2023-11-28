//
//  ProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class ProfileViewController: UIViewController {
    private var followButton = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followButtonTapped))
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ProfileAuthCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ProfileAuthHeader")
        cv.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        cv.backgroundColor = UIColor.white
        return cv
    }()
    var author: Author? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if author == nil || author?.id == Auth.auth().currentUser?.uid {
            mySetup()
            FirebaseStorageManager.shared.getAuth { author in
                self.author = author
            }
        } else {
            othersSetup()
        }
        if let profileID = self.author?.id {
            if profileID == Auth.auth().currentUser?.uid ?? "" {
                FirebaseStorageManager.shared.getAuth { author in
                    self.author = author
                }
            }
        }
    }
    
    func othersSetup() {
        if author?.followers?.contains(Auth.auth().currentUser?.uid ?? "qq") == true {
            followButton = UIBarButtonItem(title: "Following", style: .plain, target: self, action: #selector(unfollowButtonTapped))
        } else if author?.pending?.contains(Auth.auth().currentUser?.uid ?? "qq") == true {
            followButton = UIBarButtonItem(title: "Requesting", style: .plain, target: self, action: #selector(unrequestButtonTapped))
        } else {
            followButton = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followButtonTapped))
        }
        followButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = followButton
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = author?.name
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }
    
    func mySetup() {
        let setButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(setButtonTapped))
        setButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = setButton
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "My Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }
    
    func setup() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @objc func setButtonTapped() {
        let secondViewController = EditProfileViewController()
        secondViewController.author = self.author
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func heartButtonTapped() {
        
    }
    
    @objc func followButtonTapped() {
        FirebaseStorageManager.shared.sendFriendRequest(toUserID: author?.id ?? "") { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                self.followButton = UIBarButtonItem(title: "Requesting", style: .plain, target: self, action: #selector(self.unrequestButtonTapped))
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
                print("Friend request sent successfully")
            }
        }
    }
    @objc func unfollowButtonTapped() {
        FirebaseStorageManager.shared.removeFriend(friendID: author?.id ?? "") { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                self.followButton = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(self.followButtonTapped))
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
                print("unfollow")
            }
        }
    }
    @objc func unrequestButtonTapped() {
        FirebaseStorageManager.shared.cancelFriendRequest(toUserID: author?.id ?? "") { error in
            if let error = error {
                print("Error sending friend request: \(error)")
            } else {
                self.followButton = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(self.followButtonTapped))
                self.followButton.tintColor = UIColor.lightBrown()
                self.navigationItem.rightBarButtonItem = self.followButton
                print("unrequest")
            }
        }
    }
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let paddingSpace =  sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem*1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 300)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return author?.post?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as? ProfileCollectionViewCell else {
            fatalError("Unable to dequeue ProfileCell")
        }
        if let imageURL = author?.post?[indexPath.row].image {
            cell.image.kf.setImage(with: URL(string: imageURL))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileAuthHeader", for: indexPath) as? ProfileAuthCollectionViewCell else {
            fatalError("Unable to dequeue ProfileAuthCollectionViewCell")
        }
        headerView.author = self.author
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FirebaseStorageManager.shared.fetchSpecificData(id: author?.post?[indexPath.row].id ?? "") { article in
            let secondViewController = DetailPageViewController()
            secondViewController.article = article
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
}
