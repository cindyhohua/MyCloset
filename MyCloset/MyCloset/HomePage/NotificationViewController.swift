//
//  NotificationViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/25.
//

import UIKit
import SnapKit
import Kingfisher

class FriendRequestCell: UITableViewCell {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .green
        return button
    }()

    let rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "nosign"), for: .normal)
        button.tintColor = .red
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(rejectButton)

        profileImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(profileImageView.snp.height)
        }

        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }

        emailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
        }

        acceptButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(rejectButton.snp.leading).offset(-8)
            make.width.height.equalTo(40)
        }

        rejectButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-8)
            make.width.height.equalTo(40)
        }
    }
}

class NotificationViewController: UIViewController {
    var pendingAuthors: [Author] = []
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPendingAuthors()
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "friendRequestCell")
    }

    func fetchPendingAuthors() {
        FirebaseStorageManager.shared.listenForPendingRequests { [weak self] pendingAuthors in
            self?.pendingAuthors = pendingAuthors
            self?.tableView.reloadData()
            print("Pending friend requests: \(pendingAuthors)")
        }
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingAuthors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! FriendRequestCell
        let author = pendingAuthors[indexPath.row]

        cell.nameLabel.text = author.name
        cell.emailLabel.text = author.email
        cell.tag = indexPath.row

        if let imageURLString = author.image, let imageURL = URL(string: imageURLString) {
            cell.profileImageView.kf.setImage(with: imageURL)
        }

        cell.acceptButton.addTarget(self, action: #selector(acceptButtonTapped(_:)), for: .touchUpInside)
        cell.acceptButton.isUserInteractionEnabled = true
        cell.rejectButton.addTarget(self, action: #selector(rejectButtonTapped(_:)), for: .touchUpInside)
        cell.rejectButton.isUserInteractionEnabled = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondViewController = ProfileViewController()
        FirebaseStorageManager.shared.getSpecificAuth(id: pendingAuthors[indexPath.row].id ) { author in
            secondViewController.author = self.pendingAuthors[indexPath.row]
            secondViewController.othersSetup()
        }
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc func acceptButtonTapped(_ sender: UIButton) {
        let author = pendingAuthors[sender.tag]
        FirebaseStorageManager.shared.acceptFriendRequest(authorID: author.id) {_ in
            self.tableView.reloadData()
        }
    }

    @objc func rejectButtonTapped(_ sender: UIButton) {
        let author = pendingAuthors[sender.tag]
        FirebaseStorageManager.shared.rejectFriendRequest(authorID: author.id) {_ in
            self.tableView.reloadData()
        }
    }
}
