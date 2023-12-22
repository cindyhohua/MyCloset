//
//  TopRankingViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/26.
//

import UIKit
import SnapKit
import PullToRefreshKit

class TopRankingViewController: UIViewController {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cview.translatesAutoresizingMaskIntoConstraints = false
        cview.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        cview.backgroundColor = UIColor.white
        return cview
    }()
    
    var articles: [Article]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        FirebaseStorageManager.shared.fetchData { articles in
            self.articles = articles
            self.collectionView.reloadData()
        }
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"), style: .plain,
            target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Top Ranking"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        let codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44),
            buttonTitle: ["熱門", "最新", "含紙娃娃"])
        view.addSubview(codeSegmented)
        codeSegmented.backgroundColor = UIColor.lightLightBrown()
        codeSegmented.delegate = self
        
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension TopRankingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let paddingSpace =  sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem*1.4)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return sectionInsets
    }
}

extension TopRankingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileCell",
            for: indexPath) as? ProfileCollectionViewCell else {
            fatalError("Unable to dequeue ProfileCell")
        }
        if let imageURL = articles?[indexPath.row].imageURL {
            cell.image.kf.setImage(with: URL(string: imageURL))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let secondViewController = DetailPageViewController()
        FirebaseStorageManager.shared.fetchSpecificData(id: articles?[indexPath.row].id ?? "") { article in
            secondViewController.article = article
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
}

extension TopRankingViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        switch index {
        case 0: navigationItem.title = "Top Ranking"
            self.articles = []
            self.collectionView.reloadData()
            FirebaseStorageManager.shared.fetchData { articles in
                self.articles = articles
                self.collectionView.reloadData()
            }
        case 1: navigationItem.title = "Latest Post"
            self.articles = []
            self.collectionView.reloadData()
            FirebaseStorageManager.shared.fetchLatestData { articles in
                self.articles = articles
                self.collectionView.reloadData()
            }
        case 2: navigationItem.title = "Include Paper Doll"
            self.articles = []
            self.collectionView.reloadData()
            FirebaseStorageManager.shared.fetchDollData { articles in
                self.articles = articles
                self.collectionView.reloadData()
            }
        default: navigationItem.title = "Top Ranking"
        }
    }
}
