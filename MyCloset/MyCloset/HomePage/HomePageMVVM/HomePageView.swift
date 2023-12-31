//
//  HomePageView.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/31.
//

import UIKit
import SnapKit
import Kingfisher
import PullToRefreshKit

class HomePageViewController: UIViewController {
    private let tableView = UITableView()
    private let createPostButton = UIButton()
    private let viewModel = HomePageViewModel()

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
        setupNotifications()
        viewModel.updateFMC()
        viewModel.getFollowingArticle {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRefreshHeader()
        observerTrigger()
    }

    @objc private func observerTrigger() {
        viewModel.fetchNotSeenNotifications { [weak self] notSeenNumber in
            self?.updateBadge(count: notSeenNumber)
        }
    }

    private func setupView() {
        setupTableView()
        setupNavigationBar()
        setupCreatePostButton()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.register(HomePageTableCell.self, forCellReuseIdentifier: "homepage")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.lightBrown(),
            .font: UIFont.roundedFont(ofSize: 25)
        ]
        let leftButton = makeLeftBarButton()
        leftButton.tintColor = .lightBrown()
        let rightBarButton = makeRightBarButton()
        rightBarButton.tintColor = .lightBrown()
        let searchButton = makeSearchBarButton()
        searchButton.tintColor = .lightBrown()
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItems = [rightBarButton, searchButton]
        navigationItem.title = "Home Page"
    }

    private func setupCreatePostButton() {
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

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observerTrigger),
            name: Notification.Name("NotificationUpdate"),
            object: nil
        )
    }

    private func setupRefreshHeader() {
        tableView.configRefreshHeader(container: self) { [weak self] in
            self?.viewModel.getFollowingArticle {
                self?.tableView.reloadData()
                self?.tableView.switchRefreshHeader(to: .normal(.success, 0.5))
            }
        }
    }

    private func makeLeftBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(systemName: "crown.fill"),
            style: .plain,
            target: self,
            action: #selector(leftButtonTapped)
        )
    }

    private func makeRightBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(customView: notificationButton)
    }

    private func makeSearchBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
    }

    private func updateBadge(count: Int) {
        if count > 0 {
            notificationButton.addBadge(number: count)
        } else {
            notificationButton.removeBadge()
        }
    }

    @objc private func createPost() {
        let secondViewController = NewPostViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc private func leftButtonTapped() {
        let secondViewController = TopRankingViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc private func rightButtonTapped() {
        let secondViewController = NotificationViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc private func searchButtonTapped() {
        let secondViewController = SearchViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homepage", for: indexPath) as? HomePageTableCell else {
            fatalError("Can't find cell")
        }
        cell.isUserInteractionEnabled = true
        cell.nameLabel.text = viewModel.articles[indexPath.row].author.name
        cell.cellImageView.kf.setImage(with: URL(string: viewModel.articles[indexPath.row].imageURL))
        if let imageURL = viewModel.articles[indexPath.row].author.image {
            cell.profileImage.kf.setImage(with: URL(string: imageURL))
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width * 1.4
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        tableView.deselectRow(at: selectedIndexPath!, animated: true)
        let secondViewController = DetailPageViewController()
        secondViewController.article = viewModel.articles[indexPath.row]
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}
