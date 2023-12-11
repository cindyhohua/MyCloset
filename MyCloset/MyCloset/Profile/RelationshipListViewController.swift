//
//  RelationshipListViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/11.
//

import UIKit
import SnapKit

class RelationshipListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var friends: [Author] = [] {
        didSet {
            likeAmount = friends.count
        }
    }
    
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
        view.backgroundColor = .white
        let codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44),
            buttonTitle: ["Following", "Followers", "Block List"])
        codeSegmented.backgroundColor = UIColor.white
        codeSegmented.delegate = self
        view.addSubview(codeSegmented)
        view.addSubview(tableView)
        tableView.frame = view.bounds
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain,
                                         target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(codeSegmented.snp.bottom).offset(2)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
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
            self.tableView.tableHeaderView = self.createTableHeaderView()
        }
    }
    
    private func createTableHeaderView() -> UIView {
        let headerView = AmountHeaderView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        headerView.totalLikes = self.friends.count
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

extension RelationshipListViewController: SegmentControlDelegate {
    func changeToIndex(_ manager: SegmentView, index: Int) {
        switch index {
        case 0:
            FirebaseStorageManager.shared.getAuth { author in
                self.friends = []
                self.fetchData(friendList: author.following ?? [])
            }
        case 1:
            FirebaseStorageManager.shared.getAuth { author in
                self.friends = []
                self.fetchData(friendList: author.followers ?? [])
            }
        case 2:
            FirebaseStorageManager.shared.getAuth { author in
                self.friends = []
                self.fetchData(friendList: author.blockedUsers ?? [])
            }
        default:
            FirebaseStorageManager.shared.getAuth { author in
                self.friends = []
                self.fetchData(friendList: author.following ?? [])
            }
        }
    }
}

class AmountHeaderView: UIView {

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.brown
        return label
    }()

    var totalLikes: Int = 0 {
        didSet {
            likesLabel.text = "Amount: \(totalLikes)"
        }
    }
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightLightBrown()
        label.text = ""
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
