//
//  RelationshipListView.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/18.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class RelationshipListView: UIViewController, SegmentControlDelegate {

    let viewModel = RelationshipListViewModel()
    private let headerView = AmountHeaderView()
    private let disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.register(FriendListCell.self, forCellReuseIdentifier: "FriendCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.backgroundColor = .white
        let codeSegmented = SegmentView(
            frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44),
            buttonTitle: viewModel.buttonTitle)
        codeSegmented.backgroundColor = UIColor.white
        codeSegmented.delegate = self
        view.addSubview(codeSegmented)
        view.addSubview(tableView)
        tableView.frame = view.bounds
        let leftButton = UIBarButtonItem(
            image: viewModel.backButtonImage, style: .plain,
            target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = leftButton
        leftButton.tintColor = UIColor.lightBrown()
        tableView.snp.makeConstraints { make in
            make.top.equalTo(codeSegmented.snp.bottom).offset(2)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
        tableView.tableHeaderView = headerView
    }

    func changeToIndex(_ manager: SegmentView, index: Int) {
        FirebaseStorageManager.shared.getAuth { [weak self] author in
            guard let self = self else { return }
            var friendList: [String] = []
            switch index {
            case 0: friendList = author.following ?? []
            case 1: friendList = author.followers ?? []
            case 2: friendList = author.blockedUsers ?? []
            default: friendList = author.following ?? []
            }
            self.viewModel.fetchData(friendList: friendList)
        }
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupBindings() {
        // Bind friends from ViewModel to the tableView
        viewModel.friends.bind(
            to: tableView.rx.items(
                cellIdentifier: "FriendCell",
                cellType: FriendListCell.self)) { _, friend, cell in
                    cell.configure(with: friend.name)
                }.disposed(by: disposeBag)

        // Handle selection
        tableView.rx.modelSelected(Author.self)
            .subscribe(onNext: { [weak self] author in
                let secondVC = OthersProfileViewController()
                secondVC.author = author
                self?.navigationController?.pushViewController(secondVC, animated: true)
            }).disposed(by: disposeBag)

        // Bind likeAmount to a header view
        viewModel.likeAmount
            .observe(on: MainScheduler.instance)
            .bind { [weak self] amount in
                self?.headerView.amount = amount
            }.disposed(by: disposeBag)

        viewModel.likeAmount
            .observe(on: MainScheduler.instance)
            .bind { [weak headerView] amount in
                headerView?.amount = amount
            }.disposed(by: disposeBag)
    }
}

//class RelationshipListView: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    let viewModel = RelationshipListViewModel()
//
//    private lazy var tableView: UITableView = {
//        let table = UITableView()
//        table.dataSource = self
//        table.delegate = self
//        table.separatorStyle = .none
//        table.register(FriendListCell.self, forCellReuseIdentifier: "FriendCell")
//        return table
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupViewModel()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//        let codeSegmented = SegmentView(
//            frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 44),
//            buttonTitle: viewModel.buttonTitle)
//        codeSegmented.backgroundColor = UIColor.white
//        codeSegmented.delegate = self
//        view.addSubview(codeSegmented)
//        view.addSubview(tableView)
//        tableView.frame = view.bounds
//        let leftButton = UIBarButtonItem(
//            image: UIImage(systemName: viewModel.backImageName), style: .plain,
//            target: self, action: #selector(backButtonTapped))
//        navigationItem.leftBarButtonItem = leftButton
//        leftButton.tintColor = UIColor.lightBrown()
//        tableView.snp.makeConstraints { make in
//            make.top.equalTo(codeSegmented.snp.bottom).offset(2)
//            make.leading.trailing.equalTo(view)
//            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//        }
//    }
//
//    private func setupViewModel() {
//        viewModel.dataChanged = { [weak self] in
//            self?.tableView.reloadData()
//            self?.tableView.tableHeaderView = self?.createTableHeaderView()
//        }
//    }
//
//    @objc func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    private func createTableHeaderView() -> UIView {
//        let headerView = AmountHeaderView(
//            frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
//        headerView.amount = viewModel.likeAmount
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.numberOfFriends
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "FriendCell",
//            for: indexPath) as? FriendListCell else {
//            return UITableViewCell()
//        }
//        let friend = viewModel.getFriend(at: indexPath.row)
//        cell.configure(with: friend.name)
//        cell.selectionStyle = .none
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let secondVC = ProfileViewController()
//        secondVC.author = viewModel.getFriend(at: indexPath.row)
//        self.navigationController?.pushViewController(secondVC, animated: true)
//    }
//}
//
//extension RelationshipListView: SegmentControlDelegate {
//    func changeToIndex(_ manager: SegmentView, index: Int) {
//        FirebaseStorageManager.shared.getAuth { [weak self] author in
//            guard let self = self else { return }
//            var friendList: [String] = []
//            switch index {
//            case 0: friendList = author.following ?? []
//            case 1: friendList = author.followers ?? []
//            case 2: friendList = author.blockedUsers ?? []
//            default: friendList = author.following ?? []
//            }
//            self.viewModel.fetchData(friendList: friendList)
//        }
//    }
//}
//
class AmountHeaderView: UIView {

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.brown
        return label
    }()

    var onAmountChanged: ((Int) -> Void)?
    
    var amount: Int = 0 {
        didSet {
            amountLabel.text = "Amount: \(amount)"
            onAmountChanged?(amount)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
