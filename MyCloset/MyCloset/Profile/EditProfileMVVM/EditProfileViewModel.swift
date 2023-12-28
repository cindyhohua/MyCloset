//
//  EditProfileViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/18.
//

import FirebaseAuth
import UIKit

class EditProfileViewModel {
    var author: Author? {
        didSet {
            setUpAuthor()
        }
    }
    var didSetAuthor: (() -> Void)?
    var didDeleteUser: (() -> Void)?
    var didLogOut: (() -> Void)?
    var didUpdate: (() -> Void)?
    
    func setUpAuthor() {
        didSetAuthor?()
    }
    
    func deleteUser() {
        FirebaseStorageManager.shared.deleteUser { result in
            switch result {
            case .success:
                print("帳戶已删除")
                if let currentUser = Auth.auth().currentUser {
                    currentUser.delete { error in
                        if let error = error {
                            print(error)
                        } else {
                            self.didDeleteUser?()
                        }
                    }
                } else {
                    print("無法獲取當前用戶")
                }
            case .failure(let error):
                print("刪除失敗: \(error)")
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.didLogOut?()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func updateProfile(name: String, littleWords: String, image: UIImage) {
        FirebaseStorageManager.shared.uploadImageAndGetURL(image) { [weak self] result in
            switch result {
            case .success(let downloadURL):
                DispatchQueue.main.async {
                    FirebaseStorageManager.shared.updateAuth(
                        image: downloadURL.absoluteString,
                        name: name,
                        littleWords: littleWords,
                        weight: "",
                        height: "") { _ in
                            self?.didUpdate?()
                        }
                }
            case .failure(let error):
                print("Error uploading post data to Firebase: \(error.localizedDescription)")
            }
        }
    }
}
