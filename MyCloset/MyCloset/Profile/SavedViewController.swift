//
//  SavedViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/29.
//

import UIKit
import SnapKit

class SavedViewController: UIViewController {
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    var savedPost: [Post]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        FirebaseStorageManager.shared.getAuth { author in
            self.savedPost = author.saved
            self.collectionView.reloadData()
        }
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Saved"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
}

extension SavedViewController: UICollectionViewDelegateFlowLayout {
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
}

extension SavedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPost?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as? ProfileCollectionViewCell else {
            fatalError("Unable to dequeue ProfileCell")
        }
        if let imageURL = savedPost?[indexPath.row].image {
            cell.image.kf.setImage(with: URL(string: imageURL))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FirebaseStorageManager.shared.fetchSpecificData(id: savedPost?[indexPath.row].id ?? "") { article in
            let secondViewController = DetailPageViewController()
            secondViewController.article = article
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
}



