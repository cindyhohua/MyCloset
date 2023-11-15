//
//  ViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/14.
//

import UIKit

class HomePageViewController: UIViewController {
    let tableView = UITableView()
    let createPostButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        tableView.register(HomePageTableCell.self, forCellReuseIdentifier: "homepage")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 25)]
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "crown.fill"), style: .plain, target: self, action: #selector(leftButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(rightButtonTapped))
            navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.brown
        view.addSubview(createPostButton)
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
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homepage", for: indexPath) as? HomePageTableCell else {
            fatalError("Cant find cell")
        }
        cell.isUserInteractionEnabled = true
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
