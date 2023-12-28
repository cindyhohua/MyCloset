//
//  TopRankingViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/26.
//

import UIKit
import SnapKit
import PullToRefreshKit

class TopRankingViewController: BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        FirebaseStorageManager.shared.fetchData { articles in
            self.savedPost = articles
        }
        navigationItem.title = "Top Ranking"
        setupTop()
    }
    
    func setupTop() {
        let codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44),
            buttonTitle: ["熱門", "最新", "含紙娃娃"])
        view.addSubview(codeSegmented)
        codeSegmented.backgroundColor = UIColor.lightLightBrown()
        codeSegmented.delegate = self
    }
    
    override func setCV() {
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension TopRankingViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        var title = ""
        var fetchDataFunction: (() -> Void)?

        switch index {
        case 0:
            title = "Top Ranking"
            fetchDataFunction = fetchTopRanking
        case 1:
            title = "Latest Post"
            fetchDataFunction = fetchLatestPosts
        case 2:
            title = "Include Paper Doll"
            fetchDataFunction = fetchDollData
        default:
            title = "Top Ranking"
            fetchDataFunction = fetchTopRanking
        }

        updateUI(title: title, fetchData: fetchDataFunction)
    }

    private func updateUI(title: String, fetchData: (() -> Void)?) {
        navigationItem.title = title
        savedPost = []
        fetchData?()
    }

    private func fetchTopRanking() {
        FirebaseStorageManager.shared.fetchData { articles in
            self.savedPost = articles
        }
    }

    private func fetchLatestPosts() {
        FirebaseStorageManager.shared.fetchLatestData { articles in
            self.savedPost = articles
        }
    }

    private func fetchDollData() {
        FirebaseStorageManager.shared.fetchDollData { articles in
            self.savedPost = articles
        }
    }
}
