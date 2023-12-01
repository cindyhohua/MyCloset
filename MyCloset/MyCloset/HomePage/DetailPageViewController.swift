//
//  DetailPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/15.
//

import UIKit
import FirebaseAuth
class DetailPageViewController: UIViewController {
    var article: Article?
    var tableView = UITableView()
    var commentInput = DetailPageInputCommentView()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill"), style: .plain, target: self, action: #selector(profileButtonTapped))
        rightButton.tintColor = UIColor.brown
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .brown
            navigationItem.rightBarButtonItems = [rightButton, saveButton]
            
        navigationItem.title = article?.author.name
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        setupTableView()
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped() {
        FirebaseStorageManager.shared.savePost(postId: article!.id, imageURL: article!.imageURL, time: article?.createdTime ?? 0) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("save success")
            }
        }
    }
    
    @objc func profileButtonTapped() {
        let secondViewController = ProfileViewController()
        if article?.author.id != Auth.auth().currentUser?.uid {
            FirebaseStorageManager.shared.getSpecificAuth(id: article?.author.id ?? "") { author in
                secondViewController.author = author
                secondViewController.othersSetup()
            }
        }
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}

extension DetailPageViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        view.addSubview(commentInput)
        commentInput.delegate = self
        commentInput.postId = article?.id
        commentInput.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(commentInput.snp.top)
        }
        tableView.register(DetailPageImageCell.self, forCellReuseIdentifier: "imageCell")
        tableView.register(DetailPageCommentCell.self, forCellReuseIdentifier: "commentCell")
        tableView.register(DetailPageProductCell.self, forCellReuseIdentifier: "productCell")
        tableView.register(OthersCommentCell.self, forCellReuseIdentifier: "othersComment")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            return 2 + (article?.productList.count ?? 0)
        case 1 :
            return article?.comment.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? DetailPageImageCell else {
                    fatalError("Cant find cell")
                }
                var position: [CGPoint] = []
                if article?.position.isEmpty == false {
                    for i in 0..<(article?.position.count ?? 0) {
                        position.append(CGPointMake(article?.position[i].x ?? 0 , article?.position[i].y ?? 0))
                    }
                }
                cell.isUserInteractionEnabled = true
                cell.labelTexts = article?.productList
                cell.configure(with: article?.imageURL ?? "", buttonPosition: position)
                cell.postId = article?.id
                cell.selectionStyle = .none
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? DetailPageCommentCell else {
                    fatalError("Cant find cell")
                }
                cell.configure(content: article?.content ?? "")
                cell.selectionStyle = .none
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? DetailPageProductCell else {
                    fatalError("Cant find cell")
                }
                cell.configure(product: article?.productList[indexPath.row-2] ?? Product(productName: "", productStore: "", productPrice: "", productComment: ""))
                cell.selectionStyle = .none
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "othersComment", for: indexPath) as? OthersCommentCell else {
                fatalError("Cant find cell")
            }
            cell.nameButton.setTitle(article?.comment[indexPath.row].authName, for: .normal)
            cell.commentLabel.text = article?.comment[indexPath.row].comment
            let date = Date(timeIntervalSince1970: article?.comment[indexPath.row].createdTime ?? 0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let formattedDate = dateFormatter.string(from: date)
            cell.timeLabel.text = formattedDate
            cell.selectionStyle = .none
            return cell
        }
    }
    
}

extension DetailPageViewController: DetailPageInputCommentDelegate {
    func didTapPostComment() {
        FirebaseStorageManager.shared.fetchSpecificData(id: article?.id ?? "") { article in
            self.article = article
            self.tableView.reloadData()
        }
    }

}
