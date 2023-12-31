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
    var author: Author?
    var dollImageData: Data?
    var products: [Product] = []
    
    func convertToActualPosition(_ relativePosition: CGPoint) -> CGPoint {
        let actualX = relativePosition.x * (view.bounds.width-32)
        let actualY = relativePosition.y * ((view.bounds.width-32)*1.4)
        return CGPoint(x: actualX, y: actualY)
    }
    
    func createEmptyProducts() {
        if !position.isEmpty {
            for _ in 1...position.count {
                products.append(Product(productName: "", productStore: "", productPrice: "", productComment: ""))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.lightBrown()
        navigationItem.title = "Add Item"
        navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.lightBrown(),
         NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        let nextButton = UIBarButtonItem(
            title: "Post", style: .plain,
            target: self, action: #selector(postButtonTapped))
        let addButton = UIBarButtonItem(
            title: "AddDoll", style: .plain,
            target: self, action: #selector(addButtonTapped))
        nextButton.tintColor = UIColor.lightBrown()
        addButton.tintColor = UIColor.lightBrown()
        navigationItem.rightBarButtonItems = [nextButton, addButton]
        actualPositions = position.map { convertToActualPosition($0) }
        createEmptyProducts()
        print("qqqq", products)
        setupTableView()
        FirebaseStorageManager.shared.getAuth { author in
            self.author = author
        }
    }
    
    @objc func addButtonTapped() {
        let secondVC = MineDollChooseViewController()
        secondVC.delegate = self
        self.present(secondVC, animated: true)
    }
    
    @objc func postButtonTapped() {
        print(products)
        var content = ""
        guard let cellContent = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? NewPostCommentCell else {
            return
        }
        content = cellContent.textView.textView.text ?? ""
        FirebaseStorageManager.shared.uploadImageAndGetURL(selectedImage!) { [weak self] result in
            switch result {
            case .success(let downloadURL):
                if let dollImageData = self?.dollImageData {
                    FirebaseStorageManager.shared.uploadImageAndGetURL(
                        UIImage(data: dollImageData)!) { [weak self] result in
                        switch result {
                        case .success(let downloadDollURL):
                            guard let auth = self?.author else {return}
                            FirebaseStorageManager.shared.addArticle(
                                auth: auth, imageURL: downloadURL.absoluteString, content: content,
                                positions: self?.position ?? [CGPoint(x: -10, y: -10)],
                                productList: self?.products ?? [], dollImageURL: downloadDollURL.absoluteString) { _ in
                                    guard let viewControllers = self?.navigationController?.viewControllers
                                    else { return }
                                    for controller in viewControllers where controller is HomePageViewController {
                                        self?.navigationController?.popToViewController(controller, animated: true)
                                    }
                                }
                        case .failure(let error):
                            print("Error uploading post data to Firebase: \(error.localizedDescription)")
                        }
                    }
                } else {
                    guard let auth = self?.author else {return}
                    FirebaseStorageManager.shared.addArticle(
                        auth: auth, imageURL: downloadURL.absoluteString, content: content,
                        positions: self?.position ?? [CGPoint(x: -10, y: -10)],
                        productList: self?.products ?? [], dollImageURL: "") { _ in
                            guard let viewControllers = self?.navigationController?.viewControllers else { return }
                            for controller in viewControllers where controller is HomePageViewController {
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

extension NewPostSecondStepViewController: UITableViewDelegate, UITableViewDataSource, NewPostProductCellDelegate {
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
        tableView.register(NewPostProductCell.self, forCellReuseIdentifier: "product")
        tableView.separatorStyle = .none
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + position.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "image", for: indexPath) as? NewPostImageCell else {
                fatalError("Cant find cell")
            }
            cell.configure(with: selectedImage!, buttonPosition: actualPositions)
            cell.isUserInteractionEnabled = false
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "comment", for: indexPath) as? NewPostCommentCell else {
                fatalError("Cant find cell")
            }
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            return cell
        default:
//            guard let cell = tableView.dequeueReusableCell(
//                withIdentifier: "product", for: indexPath) as? NewPostProductCell else {
//                fatalError("Cant find cell")
//            }
            let cell = NewPostProductCell()
            cell.delegate = self
            cell.numberLabel.text = "品項\(indexPath.row-1) :"
            cell.nameLabel.text = products[indexPath.row-2].productName
            cell.storeLabel.text = products[indexPath.row-2].productStore
            cell.priceLabel.text = products[indexPath.row-2].productPrice
            cell.commentsLabel.text = products[indexPath.row-2].productComment
            cell.fromClosetButton.tag = indexPath.row
            cell.fromClosetButton.addTarget(self, action: #selector(fromClosetButtonTapped(_:)), for: .touchUpInside)
            cell.isUserInteractionEnabled = true
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func textFieldDidChange(text: String?, in cell: NewPostProductCell) {
        guard let indexPath = tableView.indexPath(for: cell), indexPath.row >= 2 else {
            return
        }
        
        let index = indexPath.row - 2
        if index < products.count {
            products[index].productName = cell.nameLabel.text ?? ""
            products[index].productStore = cell.storeLabel.text ?? ""
            products[index].productPrice = cell.priceLabel.text ?? ""
            products[index].productComment = cell.commentsLabel.text ?? ""
        }
    }
    
    @objc func fromClosetButtonTapped(_ sender: UIButton) {
        let secondVC = ImportFromClosetViewController()
        secondVC.delegate = self
        secondVC.indexPathRow = sender.tag
        self.present(secondVC, animated: true)
    }
}

extension NewPostSecondStepViewController: ClosetToPost {
    func closetToPost(cloth: ClothesStruct, index: Int) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NewPostProductCell else {
            return
        }
        cell.nameLabel.text = cloth.item
        cell.storeLabel.text = cloth.store
        cell.priceLabel.text = cloth.price
        cell.commentsLabel.text = cloth.content
        
        let index2 = index - 2
        if index2 < products.count {
            products[index2].productName = cell.nameLabel.text ?? ""
            products[index2].productStore = cell.storeLabel.text ?? ""
            products[index2].productPrice = cell.priceLabel.text ?? ""
            products[index2].productComment = cell.commentsLabel.text ?? ""
        }
    }
}

extension NewPostSecondStepViewController: MineDollToPost {
    func mineDollToPost(dollImageData: Data) {
        self.dollImageData = dollImageData
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewPostImageCell else {
            return
        }
        cell.dollImageView.image = UIImage(data: dollImageData)
    }
    
}
