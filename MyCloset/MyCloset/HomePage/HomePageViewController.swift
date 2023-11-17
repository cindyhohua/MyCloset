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
    var test: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseStorageManager.shared.fetchData { url in
            print("qqq",url)
            self.test = url
            self.setupView()
        }
//        setupView()
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
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(rightButtonTapped))
            navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.lightBrown()
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
    
    @objc func createPost() {
        let secondViewController = NewPostViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func leftButtonTapped() {
        print("left")
    }
    
    @objc func rightButtonTapped() {
        print("right")
    }
}

extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homepage", for: indexPath) as? HomePageTableCell else {
            fatalError("Cant find cell")
        }
        cell.isUserInteractionEnabled = true
        cell.cellImageView.kf.setImage(with: URL(string: test))
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
        navigationController?.pushViewController(secondViewController, animated: true)
    }
}
