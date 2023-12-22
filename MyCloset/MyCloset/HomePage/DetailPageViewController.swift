//
//  DetailPageViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/15.
//

import UIKit
import FirebaseAuth
import Kingfisher
class DetailPageViewController: UIViewController {
    private var saveButton: UIBarButtonItem!
    var article: Article? {
        didSet {
            FirebaseStorageManager.shared.getAuth { [weak self] author in
                if let articleID = self?.article?.id,
                   let savedArticles = author.saved,
                   !savedArticles.isEmpty {
                    self?.saveOrNot = savedArticles.contains { $0.id == articleID }
                } else {
                    self?.saveOrNot = false
                }
            }

            if let articleID = article?.id,
               let authorID = article?.author.id {
                commentInput.postId = articleID
                commentInput.posterId = authorID
            } else {
                commentInput.postId = nil
                commentInput.posterId = nil
            }
        }
    }

    var saveOrNot: Bool? {
        didSet {
            DispatchQueue.main.async {
                if let save = self.saveOrNot {
                    if let button = self.saveButton {
                        if save {
                            button.tintColor = .brown
                        } else {
                            button.tintColor = .lightLightBrown()
                        }
                    }
                }
            }
        }
    }

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
        saveButton = UIBarButtonItem(
            image: UIImage(systemName: "bookmark.fill"),
            style: .plain, target: self, action: #selector(saveButtonTapped))
        if let save = self.saveOrNot, let button = self.saveButton {
            if save {
                button.tintColor = .brown
            } else {
                button.tintColor = .lightLightBrown()
            }
        }
        view.backgroundColor = .white
        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash.fill"),
            style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = UIColor.lightBrown()
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil.circle"),
            style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.tintColor = UIColor.lightBrown()
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
        leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(
            title: article?.author.name,
            style: .plain, target: self, action: #selector(profileButtonTapped))
        let reportButton = UIBarButtonItem(
            image: UIImage(systemName: "exclamationmark.triangle"),
            style: .plain, target: self, action: #selector(reportButtonTapped))
        rightButton.tintColor = UIColor.brown
        reportButton.tintColor = UIColor.lightBrown()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        flexibleSpace.width = 20
        navigationItem.leftBarButtonItems = [leftButton, flexibleSpace, rightButton]
        if article?.author.id == Auth.auth().currentUser?.uid {
            navigationItem.rightBarButtonItems = [editButton, deleteButton, reportButton, saveButton]
        } else {
            navigationItem.rightBarButtonItems = [reportButton, saveButton]
        }
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brown,
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        setupTableView()
    }
    
    @objc func editButtonTapped() {
        let secondVC = NewPostSecondStepViewController()
        secondVC
        secondVC.products = article?.productList ?? []
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc func deleteButtonTapped() {
        let alertController = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.performDelete()
        }
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }

    func performDelete() {
        FirebaseStorageManager.shared.deletePost(postId: self.article?.id ?? "") { error in
            if let error = error {
                print(error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func reportButtonTapped() {
        let alertController = UIAlertController(
            title: "Report",
            message: "Choose a reason for reporting",
            preferredStyle: .actionSheet)
        
        let reasons = ["Inappropriate Content", "Harassment", "Spam"]
        for reason in reasons {
            let action = UIAlertAction(title: reason, style: .default) { _ in
                FirebaseStorageManager.shared.reportOther(
                    authorId: self.article?.author.id ?? "",
                    postId: self.article?.id ?? "",
                    reportReason: reason) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.showSuccessAlert()
                    }
                }
            }
            alertController.addAction(action)
        }
        
        let customAction = UIAlertAction(title: "Other Reason", style: .default) { _ in
            self.showCustomReportAlert()
        }
        alertController.addAction(customAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(
                x: self.view.bounds.midX,
                y: self.view.bounds.midY,
                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessAlert() {
        let successAlert = UIAlertController(
            title: "Report Submitted",
            message: "Thank you for reporting. We will review your report.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        successAlert.addAction(okAction)
        present(successAlert, animated: true, completion: nil)
    }
    
    func showCustomReportAlert() {
        let customReportAlert = UIAlertController(
            title: "Custom Report",
            message: "Please enter your report reason", preferredStyle: .alert)
        customReportAlert.addTextField { textField in
            textField.placeholder = "Enter your reason"
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
            if let reason = customReportAlert.textFields?.first?.text, !reason.isEmpty {
                FirebaseStorageManager.shared.reportOther(
                    authorId: self.article?.author.id ?? "",
                    postId: self.article?.id ?? "", reportReason: reason) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.showSuccessAlert()
                    }
                }
            }
        }
        customReportAlert.addAction(submitAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        customReportAlert.addAction(cancelAction)
        
        present(customReportAlert, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped() {
        print("save")
        self.saveOrNot = !(saveOrNot ?? false)
        FirebaseStorageManager.shared.savePost(
            postId: article!.id,
            imageURL: article!.imageURL,
            time: article?.createdTime ?? 0) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("save success")
            }
        }
    }
    
    @objc func profileButtonTapped() {
        let secondViewController = ProfileViewController()
        FirebaseStorageManager.shared.getSpecificAuth(id: article?.author.id ?? "") { result in
            switch result {
            case .success(let author):
                secondViewController.author = author
                self.navigationController?.pushViewController(secondViewController, animated: true)
            case .failure(let failure):
                print(failure)
            }
            
        }
        
    }
}

extension DetailPageViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        view.addSubview(commentInput)
        commentInput.delegate = self
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
        case 0:
            return 2 + (article?.productList.count ?? 0)
        case 1:
            return article?.comment.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "imageCell",
                    for: indexPath) as? DetailPageImageCell else {
                    fatalError("Cant find cell")
                }
                var position: [CGPoint] = []
                if article?.position.isEmpty == false {
                    for indexI in 0..<(article?.position.count ?? 0) {
                        position.append(CGPointMake(
                                article?.position[indexI].xPosition ?? 0,
                                article?.position[indexI].yPosition ?? 0)
                        )
                    }
                }
                cell.isUserInteractionEnabled = true
                cell.labelTexts = article?.productList
                cell.configure(
                    with: article?.imageURL ?? "",
                    dollImage: article?.dollImageURL ?? "",
                    buttonPosition: position)
                cell.postId = article?.id
                cell.selectionStyle = .none
                cell.authorId = article?.author.id
                cell.delegate = self
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "commentCell",
                    for: indexPath) as? DetailPageCommentCell else {
                    fatalError("Cant find cell")
                }
                cell.configure(content: article?.content ?? "", time: article?.createdTime ?? 0)
                cell.selectionStyle = .none
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "productCell",
                    for: indexPath) as? DetailPageProductCell else {
                    fatalError("Cant find cell")
                }
                cell.configure(
                    product: article?.productList[indexPath.row-2] ?? Product(
                        productName: "",
                        productStore: "",
                        productPrice: "",
                        productComment: ""))
                cell.selectionStyle = .none
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "othersComment",
                for: indexPath) as? OthersCommentCell else {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            var blocked: [String] = []
            FirebaseStorageManager.shared.getAuth { author in
                blocked += author.blockedUsers ?? []
                blocked += author.blockedByUsers ?? []
                if let authId = self.article?.comment[indexPath.row].authId, !blocked.contains(authId) {
                    print(authId)
                    let secondVC = ProfileViewController()
                    FirebaseStorageManager.shared.getSpecificAuth(id: authId) { result in
                        switch result {
                        case .success(let author):
                            secondVC.author = author
                            self.navigationController?.pushViewController(secondVC, animated: true)
                        case .failure(let failure):
                            print(failure)
                        }
                        
                    }
                }
            }
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

extension DetailPageViewController: LongPressDelegate {
    func longPress() {
        let secondVC = FriendListViewController()
        secondVC.likeAmount = self.article?.like ?? 0
        secondVC.fetchData(friendList: self.article?.whoLiked ?? [])
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
}
