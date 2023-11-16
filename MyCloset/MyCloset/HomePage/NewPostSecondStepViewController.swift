//
//  NewPostSecondStepViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import UIKit
import SnapKit

class NewPostSecondStepViewController: UIViewController {
    var position: [CGPoint] = []
    var selectedImage: UIImage?
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Add Item"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(), NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        let nextButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postButtonTapped))
        nextButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = true
        print(position)
        setupTableView()
    }
    
    @objc func postButtonTapped() {
        print("Post")
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        for controller in viewControllers {
            if controller is HomePageViewController {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        
    }
}

extension NewPostSecondStepViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.register(NewPostImageCell.self, forCellReuseIdentifier: "image")
        tableView.register(NewPostCommentCell.self, forCellReuseIdentifier: "comment")
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + position.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? NewPostImageCell else {
                fatalError("Cant find cell")
            }
            cell.configure(with: selectedImage!, buttonPosition: position)
            cell.isUserInteractionEnabled = false
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as? NewPostCommentCell else {
                fatalError("Cant find cell")
            }
            cell.isUserInteractionEnabled = false
            return cell
        default:
            let cell = NewPostProductCell()
            cell.numberLabel.text = "品項\(indexPath.row-1) :"
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    
}
