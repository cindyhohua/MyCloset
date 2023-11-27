//
//  MineDollViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/27.
//

import UIKit
import SnapKit

class MineDollViewController: UIViewController {
    var mineDoll: [Mine]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mineDoll =  CoreDataManager.shared.fetchAllMineData()
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

extension MineDollViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let paddingSpace =  sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem*2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return sectionInsets
    }
}

extension MineDollViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mineDoll?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as? ProfileCollectionViewCell else {
            fatalError("Unable to dequeue ProfileCell")
        }
        if let imageData = mineDoll?[indexPath.row].myWearing {
            cell.image.image = UIImage(data: imageData) ?? UIImage(named: "Image")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let secondViewController = MineDollDetailViewController()
        secondViewController.mineDoll = self.mineDoll?[indexPath.row]
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}



