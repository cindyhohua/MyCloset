//
//  ProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/22.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class ProfileViewController: UIViewController {
    var author: Author? {
        didSet {
            navigationItem.title = author?.name
            self.collectionView.reloadData()
        }
    }
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cview.translatesAutoresizingMaskIntoConstraints = false
        cview.register(ProfileAuthCollectionViewCell.self,
                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                       withReuseIdentifier: "ProfileAuthHeader")
        cview.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        cview.backgroundColor = UIColor.white
        return cview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let paddingSpace =  sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem*1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 300)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return author?.post?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileCell", for: indexPath
        ) as? ProfileCollectionViewCell else {
            fatalError("Unable to dequeue ProfileCell")
        }
        if let imageURL = author?.post?[indexPath.row].image {
            cell.image.kf.setImage(with: URL(string: imageURL))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "ProfileAuthHeader", for: indexPath
        ) as? ProfileAuthCollectionViewCell else {
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
