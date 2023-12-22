//
//  EditProfileView.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/18.
//
import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class EditProfileView: UIViewController {
    let viewModel = EditProfileViewModel()
    var imageView = UIImageView()
    var uploadImageButton = UIButton()
    var nameTextField = UITextField()
    var littleWordsTextField = UITextField()
    
    var privateOrNotButton = UIButton()
    var relationshipButton = UIButton()
    var logoutButton = UIButton()
    var deleteAccountButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.didSetAuthor = { [weak self] in
            do {
                print("qqq3", self?.viewModel.author)
                guard let author = self?.viewModel.author else { return }
                if let image = author.image {
                    self?.imageView.kf.setImage(with: URL(string: image))
                } else {
                    self?.imageView.image = UIImage(named: "placeHolder")
                }
                self?.nameTextField.text = author.name
                self?.littleWordsTextField.text = author.littleWords
            } catch {
                print("Error: \(error)")
            }
        }

    }
    
    func setup() {
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward.circle"),
            style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(
            title: "save", style: .plain, target: self,
            action: #selector(saveButtonTapped))
            navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.brown
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.brown,
            NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        if imageView.image == nil {
            imageView.image = UIImage(named: "placeHolder")
        }
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(150)
        }
        
        view.addSubview(uploadImageButton)
        uploadImageButton.setTitle("選擇照片", for: .normal)
        uploadImageButton.setTitleColor(UIColor.lightBrown(), for: .normal)
        uploadImageButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(imageView)
        }
        uploadImageButton.addTarget(self, action: #selector(uploadImageButtonTapped), for: .touchUpInside)
        
        view.addSubview(nameTextField)
        nameTextField.borderStyle = .roundedRect
        nameTextField.placeholder = "Name"
        nameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }

        view.addSubview(littleWordsTextField)
        littleWordsTextField.borderStyle = .roundedRect
        littleWordsTextField.placeholder = "little words..."
        littleWordsTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        deleteAccountButton.backgroundColor = .gray
        deleteAccountButton.layer.cornerRadius = 5
        deleteAccountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        view.addSubview(logoutButton)
        logoutButton.setTitle("登出", for: .normal)
        logoutButton.backgroundColor = .red
        logoutButton.layer.cornerRadius = 5
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(deleteAccountButton.snp.top).offset(-20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        view.addSubview(relationshipButton)
        relationshipButton.setTitle("關係列表", for: .normal)
        relationshipButton.backgroundColor = .brown
        relationshipButton.layer.cornerRadius = 5
        relationshipButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(logoutButton.snp.top).offset(-20)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        relationshipButton.addTarget(self, action: #selector(relationshipButtonTapped), for: .touchUpInside)
    }
    
    @objc func relationshipButtonTapped() {
        let secondVC = RelationshipListView()
        FirebaseStorageManager.shared.getAuth { author in
            secondVC.viewModel.fetchData(friendList: author.following ?? [])
            self.navigationController?.pushViewController(secondVC, animated: true)
        }
    }
    
    @objc func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "確定要刪除您的帳戶吗？此操作不可恢復。", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { [weak self] _ in
            FirebaseStorageManager.shared.deleteUser { result in
                switch result {
                case .success:
                    print("帳戶已删除")
                    if let currentUser = Auth.auth().currentUser {
                        currentUser.delete { error in
                            if let error = error {
                                print(error)
                            } else {
                                self?.dismiss(animated: true) {
                                    if let tabBarController = self?.tabBarController {
                                        tabBarController.selectedIndex = 0
                                    }
                                }
                            }
                        }
                    } else {
                        print("无法获取当前用户")
                    }
                case .failure(let error):
                    print("删除失败: \(error)")
                }
            }
        }))
        
        // 显示警告对话框
        self.present(alert, animated: true)
    }

    @objc func logoutButtonTapped() {
        let alertController = UIAlertController(title: "登出", message: "您確定要登出吗？", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "確認", style: .destructive, handler: { [weak self] (_) in
            do {
                try Auth.auth().signOut()
                self?.dismiss(animated: true) {
                    if let tabBarController = self?.tabBarController {
                        tabBarController.selectedIndex = 0
                    }
                }
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        
        present(alertController, animated: true)
    }

    @objc func uploadImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped() {
        print("save")
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "名字不能為空")
            return
        }
        FirebaseStorageManager.shared.uploadImageAndGetURL(imageView.image!) { [weak self] result in
            switch result {
            case .success(let downloadURL):
                DispatchQueue.main.async {
                    FirebaseStorageManager.shared.updateAuth(
                        image: downloadURL.absoluteString,
                        name: name,
                        littleWords: self?.littleWordsTextField.text ?? "",
                        weight: "",
                        height: "") { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                }
            case .failure(let error):
                print("Error uploading post data to Firebase: \(error.localizedDescription)")
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "提醒", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension EditProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// import UIKit
// import SnapKit
//
// class EditProfileView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    private var viewModel = EditProfileViewModel()
//
//    // ... 其他属性保持不变
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setup()
//        bindViewModel()
//    }
//
//    func bindViewModel() {
//        viewModel.onUpdateData = { [weak self] in
//            self?.configure()
//        }
//
//        viewModel.onShowAlert = { [weak self] title, message in
//            self?.showAlert(title: title, message: message)
//        }
//
//        viewModel.onSaveSuccess = { [weak self] in
//            self?.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    // ... 其他方法保持不变
//
//    @objc func saveButtonTapped() {
//        viewModel.saveProfile(
// name: nameTextField.text, littleWords: littleWordsTextField.text, image: imageView.image)
//    }
//
//    func configure() {
//        // 使用 viewModel.author 更新 UI
//    }
//
//    // ... 其他方法保持不变
// }
//
