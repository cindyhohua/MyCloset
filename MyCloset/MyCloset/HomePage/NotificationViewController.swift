//
//  NotificationViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/25.
//

import UIKit
import SnapKit
import Kingfisher
import PullToRefreshKit

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
            make.centerY.equalTo(contentView).offset(-10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }

        emailLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView).offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
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
    var notifications: [NotificationStruct]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        FirebaseStorageManager.shared.fetchNotifications { notifies, error  in
            self.notifications = notifies
            print(self.notifications)
        }
        setupTableView()
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        self.tableView.configRefreshHeader(container: self) { [weak self] in
            self?.fetchPendingAuthors()
            FirebaseStorageManager.shared.fetchNotifications { notifies, error  in
                self?.notifications = notifies
                self?.tableView.switchRefreshHeader(to: .normal(.success, 0.5))
            }
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPendingAuthors()
        FirebaseStorageManager.shared.resetNotificationNotSeen { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "friendRequestCell")
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.reuseIdentifier)
    }

    func fetchPendingAuthors() {
        FirebaseStorageManager.shared.fetchPendingRequests { [weak self] pendingAuthors in
            self?.pendingAuthors = pendingAuthors
            self?.tableView.reloadData()
            print("Pending friend requests: \(pendingAuthors)")
        }
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return pendingAuthors.count
        case 1:
            return notifications?.count ?? 0
        default:
            return 0
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as? FriendRequestCell {
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
            } else {
                let defaultCell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
                return defaultCell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.reuseIdentifier, for: indexPath) as? NotificationTableViewCell else {
                fatalError("Unable to dequeue NotificationTableViewCell")
            }
            
            if let notification = self.notifications?[indexPath.row] {
                cell.configure(with: notification)
            }
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let secondViewController = ProfileViewController()
            FirebaseStorageManager.shared.getSpecificAuth(id: pendingAuthors[indexPath.row].id) { author in
                secondViewController.author = author
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        } else {
            if self.notifications?[indexPath.row].postId == "" {
                let secondViewController = ProfileViewController()
                FirebaseStorageManager.shared.getSpecificAuth(id: self.notifications?[indexPath.row].authId ?? "")
                { author in
                    secondViewController.author = author
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            } else {
                let secondViewController = DetailPageViewController()
                FirebaseStorageManager.shared.fetchSpecificData(id: self.notifications?[indexPath.row].postId ?? "")
                { article in
                    secondViewController.article = article
                    self.navigationController?.pushViewController(secondViewController, animated: true)
                }
            }
        }
    }

    @objc func acceptButtonTapped(_ sender: UIButton) {
        let author = pendingAuthors[sender.tag]
        FirebaseStorageManager.shared.acceptFriendRequest(authorID: author.id) {_ in
            FirebaseStorageManager.shared.fetchNotifications { notifies, error  in
                self.fetchPendingAuthors()
                self.notifications = notifies
                self.tableView.reloadData()
            }
        }
    }

    @objc func rejectButtonTapped(_ sender: UIButton) {
        let author = pendingAuthors[sender.tag]
        FirebaseStorageManager.shared.rejectFriendRequest(authorID: author.id) {_ in
            self.fetchPendingAuthors()
            self.tableView.reloadData()
        }
    }
}

class NotificationTableViewCell: UITableViewCell {
    static let reuseIdentifier = "NotificationCell"

    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
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
        contentView.addSubview(commentLabel)
        contentView.addSubview(timeLabel)

        commentLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(16)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(contentView).inset(16)
            make.bottom.lessThanOrEqualTo(contentView).inset(16)
        }
    }
    
    func configure(with notification: NotificationStruct) {
        commentLabel.text = notification.name + " " + notification.comment

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = Date(timeIntervalSince1970: notification.createdTime)
        let dateString = dateFormatter.string(from: date)

        timeLabel.text = dateString
    }
}

