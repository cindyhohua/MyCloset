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
    }
    
    func bindViewModel() {
        viewModel.didSetAuthor = { [weak self] in
            self?.configure()
        }
        
        viewModel.didDeleteUser = { [weak self] in
            self?.dismiss(animated: true) {
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            }
        }
        
        viewModel.didLogOut = { [weak self] in
            self?.dismiss(animated: true) {
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            }
        }
        
        viewModel.didUpdate = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    private func configure() {
        imageView.kf.setImage(with: URL(string: viewModel.author?.image ?? ""))
        nameTextField.text =  viewModel.author?.name ?? ""
        littleWordsTextField.text =  viewModel.author?.littleWords ?? ""
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
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account", message: "確定要刪除您的帳戶嗎？此操作不可恢復。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "刪除", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteUser()
        }))
        self.present(alert, animated: true)
    }

    @objc func logoutButtonTapped() {
        let alertController = UIAlertController(title: "登出", message: "您確定要登出嗎？", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "確認", style: .destructive, handler: { [weak self] (_) in
            self?.viewModel.logout()
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
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "名字不能為空")
            return
        }
        self.viewModel.updateProfile(
            name: name,
            littleWords: self.littleWordsTextField.text ?? "",
            image: imageView.image!)
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
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
