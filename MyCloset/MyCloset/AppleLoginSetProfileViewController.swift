//
//  AppleLoginSetProfileViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/30.
//

import UIKit

class AppleLoginSetProfileViewController: UIViewController {
    var userId: String?
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .brown
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    @objc private func submitButtonTapped() {
        if let email = emailTextField.text, let fullName = fullNameTextField.text, let id = userId {
            print("Email: \(email), Full Name: \(fullName)")
            FirebaseStorageManager.shared.addAuth(uid: id, author: Author(email: email, id: id,
                 name: fullName, image: "", height: "", weight: "",
                 privateOrNot: false, littleWords: "", following: [],
                 followers: [], pending: [], post: [],
                 saved: [], notification: [], notificationNotSeen: 0)) { result in
                switch result {
                case .success(_) :
                    print("success")
                    if let previousVC = self.presentingViewController?.presentingViewController {
                        previousVC.dismiss(animated: true)
                    } else {
                        self.dismiss(animated: true)
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }
    
    private func setupConstraints() {
        view.addSubview(emailTextField)
        view.addSubview(fullNameTextField)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fullNameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            fullNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fullNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            submitButton.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
