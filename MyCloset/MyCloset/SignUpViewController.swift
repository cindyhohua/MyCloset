//
//  SignUpViewController.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/22.
//

import UIKit
import SnapKit
import FirebaseAuth

class SignupViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }
    @IBAction func signupButtonTapped(_ sender: AnyObject) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let nickName = nicknameTextField.text, !email.isEmpty, !password.isEmpty, !nickName.isEmpty else {
            showAlert(title: "Error", message: "Please enter an email, password and nick name.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                print("nice")
                print(authResult?.user.uid)
                let author = Author(email: email, id: authResult?.user.uid ?? "", name: nickName, image: "", height: "", weight: "", privateOrNot: false, littleWords: "", following: [], followers: [])
                FirebaseStorageManager.shared.addAuth(uid: authResult?.user.uid ?? "", author: author) { result in
                    switch result {
                    case .success(_) :
                        print("success")
                        if let previousVC = self.presentingViewController?.presentingViewController {
                            previousVC.dismiss(animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                    
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

