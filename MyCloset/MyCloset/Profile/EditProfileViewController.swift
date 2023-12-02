//
//  EditProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/23.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth

class EditProfileViewController: UIViewController {
    var author: Author? {
        didSet {
            configure()
        }
    }
    var imageView = UIImageView()
    var uploadImageButton = UIButton()
    var nameTextField = UITextField()
    var littleWordsTextField = UITextField()

    var heightTextField = UITextField()
    var weightTextField = UITextField()
    
    var privateOrNotButton = UIButton()
    var logoutButton = UIButton()
    var deleteAccountButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        let leftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward.circle"), style: .plain, target: self, action: #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = leftButton
            leftButton.tintColor = UIColor.brown
        let rightButton = UIBarButtonItem(title: "save", style: .plain, target: self, action: #selector(saveButtonTapped))
            navigationItem.rightBarButtonItem = rightButton
            rightButton.tintColor = UIColor.brown
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.brown, NSAttributedString.Key.font: UIFont.roundedFont(ofSize: 20)]
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 75
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(150)
        }
        
        view.addSubview(uploadImageButton)
        uploadImageButton.setTitle("選擇照片", for: .normal)
        uploadImageButton.setTitleColor(.white, for: .normal)
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
        
        view.addSubview(heightTextField)
        heightTextField.borderStyle = .roundedRect
        heightTextField.placeholder = "height"
        heightTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(littleWordsTextField.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        view.addSubview(weightTextField)
        weightTextField.borderStyle = .roundedRect
        weightTextField.placeholder = "weight"
        weightTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(heightTextField.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.setTitle("刪除帳號", for: .normal)
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
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true) {
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0 
                }
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
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
        if nameTextField.text?.isEmpty == false {
            FirebaseStorageManager.shared.uploadImageAndGetURL(imageView.image!) { [weak self] result in
                switch result {
                case .success(let downloadURL):
                    FirebaseStorageManager.shared.updateAuth(image: downloadURL.absoluteString,
                                                             name: self?.nameTextField.text ?? "",
                                                             littleWords: self?.littleWordsTextField.text ?? "",
                                                             weight: self?.weightTextField.text ?? "",
                                                             height: self?.heightTextField.text ?? "") { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print("Error uploading post data to Firebase: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func configure() {
        if let image = author?.image {
            imageView.kf.setImage(with: URL(string: image))
        } else {
            imageView.image = UIImage(named: "Image")
        }
        nameTextField.text = author?.name
        littleWordsTextField.text = author?.littleWords
        heightTextField.text = author?.height
        weightTextField.text = author?.weight
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
