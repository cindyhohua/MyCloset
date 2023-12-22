//
//  FriendList.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/7.
//

import UIKit
import SnapKit

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var friends: [Author] = []
    
    var likeAmount: Int = 0

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(FriendListCell.self, forCellReuseIdentifier: "FriendCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.tableHeaderView = createTableHeaderView()
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain,
                                         target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func fetchData(friendList: [String]) {
        FirebaseStorageManager.shared.fetchName(ids: friendList) { names in
            for name in names {
                self.friends.append(name)
            }
            self.tableView.reloadData()
        }
    }
    
    private func createTableHeaderView() -> UIView {
        let headerView = LikeAmountHeaderView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        headerView.totalLikes = self.likeAmount
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FriendCell",
            for: indexPath) as? FriendListCell else {
            return UITableViewCell()
        }
        cell.configure(with: friends[indexPath.row].name)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secondVC = ProfileViewController()
        secondVC.author = friends[indexPath.row]
        self.navigationController?.pushViewController(secondVC, animated: true)
    }

}

class FriendListCell: UITableViewCell {

    static let reuseIdentifier = "FriendCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(nameLabel)
        nameLabel.textColor = UIColor.brown
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    func configure(with friendName: String) {
        nameLabel.text = friendName
    }
}

class LikeAmountHeaderView: UIView {

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.brown
        return label
    }()

    var totalLikes: Int = 0 {
        didSet {
            likesLabel.text = "Total Likes: \(totalLikes)"
        }
    }
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightLightBrown()
        label.text = "有些人已經離開了，但他的愛會繼續存在。"
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(likesLabel)
        addSubview(warningLabel)
        likesLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(likesLabel.snp.bottom).offset(2)
            make.centerX.equalTo(likesLabel)
        }
    }
}

