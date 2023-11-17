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
    var actualPositions: [CGPoint] = []
    
    func convertToActualPosition(_ relativePosition: CGPoint) -> CGPoint {
        let actualX = relativePosition.x * (view.bounds.width-32)
        let actualY = relativePosition.y * ((view.bounds.width-32)*1.4)
        return CGPoint(x: actualX, y: actualY)
    }

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
        actualPositions = position.map { convertToActualPosition($0) }
        setupTableView()
    }
    
    @objc func postButtonTapped() {
        var productList: [Product] = []
        for row in 2..<tableView.numberOfRows(inSection: 0) {
            guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? NewPostProductCell else {
                continue
            }
            let name = cell.nameLabel.text ?? ""
            let store = cell.storeLabel.text ?? ""
            let price = cell.priceLabel.text ?? ""
            let comments = cell.commentsLabel.text ?? ""
            productList.append(Product(productName: name, productStore: store, productPrice: price, productComment: comments))
        }
        var content = ""
        guard let cellContent = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NewPostCommentCell else {
            return
        }
        content = cellContent.textView.text ?? ""
        FirebaseStorageManager.shared.uploadImageAndGetURL(selectedImage!) { [weak self] result in
            switch result {
            case .success(let downloadURL):
                FirebaseStorageManager.shared.addArticle(imageURL: downloadURL.absoluteString, content: content, positions: self?.position ?? [CGPoint(x: -10,y: -10)], productList: productList) { _ in
                    guard let viewControllers = self?.navigationController?.viewControllers else { return }
                    for controller in viewControllers {
                        if controller is HomePageViewController {
                            self?.navigationController?.popToViewController(controller, animated: true)
                        }
                    }
                }
            case .failure(let error):
                print("Error uploading post data to Firebase: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
            cell.configure(with: selectedImage!, buttonPosition: actualPositions)
            cell.isUserInteractionEnabled = false
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as? NewPostCommentCell else {
                fatalError("Cant find cell")
            }
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
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
