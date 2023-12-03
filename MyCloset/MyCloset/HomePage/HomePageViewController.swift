//
//  ViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/14.
//

import UIKit
import SnapKit
import Kingfisher

class HomePageViewController: UIViewController {
    let tableView = UITableView()
    let createPostButton = UIButton()
    var articles: [Article] = []
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bell.fill"), for: .normal)
        button.tintColor = .lightBrown()
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NotificationCenter.default.addObserver(self,
           selector: #selector(observerTrigger),
           name: Notification.Name("NotificationUpdate"),
           object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseStorageManager.shared.getFollowingArticles { articles in
            self.articles = articles
            self.tableView.reloadData()
        }
        FirebaseStorageManager.shared.fetchNotSeen { notSeenNumber in
            self.updateBadge(count: notSeenNumber)
        }
    }
    
    @objc func observerTrigger() {
        FirebaseStorageManager.shared.fetchNotSeen { notSeenNumber in
            self.updateBadge(count: notSeenNumber)
        }
    }
    
    func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.register(HomePageTableCell.self, forCellReuseIdentifier: "homepage")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 25)]
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "crown.fill"), style: .plain, target: self, action: #selector(leftButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        let rightBarButton = UIBarButtonItem(customView: notificationButton)
        let rightButtonSearch = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
           style: .plain, target: self, action: #selector(searchButtonTapped))
        rightButtonSearch.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItems = [rightBarButton, rightButtonSearch]
        rightBarButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Home Page"
        view.addSubview(createPostButton)
        createPostButton.setTitle("+", for: .normal)
        createPostButton.titleLabel?.font = UIFont.roundedFont(ofSize: 40)
        createPostButton.tintColor = .white
        createPostButton.snp.makeConstraints { make in
            make.trailing.equalTo(view).offset(-18)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.height.equalTo(70)
        }
        createPostButton.clipsToBounds = true
        createPostButton.layer.cornerRadius = 35
        createPostButton.backgroundColor = UIColor.lightBrown()
        createPostButton.addTarget(self, action: #selector(createPost), for: .touchUpInside)
        
    }
    
    func updateBadge(count: Int) {
        if count > 0 {
            notificationButton.addBadge(number: count)
        } else {
            notificationButton.removeBadge()
        }
    }
    
    @objc func createPost() {
        let secondViewController = NewPostViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func leftButtonTapped() {
        let secondViewController = TopRankingViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func rightButtonTapped() {
        print("tapped")
        let secondViewController = NotificationViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    @objc func searchButtonTapped() {
        let secondViewController = SearchViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homepage", for: indexPath) as? HomePageTableCell else {
            fatalError("Cant find cell")
        }
        cell.isUserInteractionEnabled = true
        cell.nameLabel.text = articles[indexPath.row].author.name
        cell.cellImageView.kf.setImage(with: URL(string: articles[indexPath.row].imageURL))
        if let imageURL = articles[indexPath.row].author.image {
            cell.profileImage.kf.setImage(with: URL(string: imageURL))
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (UIScreen.main.bounds.width*1.4)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: selectedIndexPath!, animated: true)
        let secondViewController = DetailPageViewController()
        secondViewController.article = articles[indexPath.row]
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}
