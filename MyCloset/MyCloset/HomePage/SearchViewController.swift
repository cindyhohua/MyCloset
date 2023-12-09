//
//  SearchViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/25.
//

import UIKit
import SnapKit
import FirebaseAuth

class SearchViewController: UIViewController {

    var searchBar = UISearchBar()
    var tableView = UITableView()

    var searchResults: [Author] = []

    let firebaseManager = FirebaseStorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupSearchBar()
        setupTableView()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Search Friend"
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
         NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func setupSearchBar() {
        view.addSubview(searchBar)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(50) // Adjust the height as needed
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    func searchFriends(query: String) {
        firebaseManager.searchFriends(query: query) { [weak self] (searchResults) in
            self?.searchResults = searchResults
            self?.tableView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFriends(query: searchText)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FriendCell",
            for: indexPath) as? FriendCell else {return FriendCell()}
        let friend = searchResults[indexPath.row]

        cell.nameLabel.text = friend.name
        cell.emailLabel.text = friend.email

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondViewController = ProfileViewController()
        FirebaseStorageManager.shared.getSpecificAuth(id: searchResults[indexPath.row].id) { result in
            switch result {
            case .success(let author):
                secondViewController.author = author
                self.navigationController?.pushViewController(secondViewController, animated: true)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

class FriendCell: UITableViewCell {

    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()

    var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    private func setupUI() {
        addSubview(nameLabel)
        addSubview(emailLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

    }

    func configure(with friend: Author) {
        nameLabel.text = friend.name
        emailLabel.text = friend.email
    }
}
