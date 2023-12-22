//
//  EditProfileViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/18.
//

// import UIKit

class EditProfileViewModel {
    var author: Author? {
        didSet {
            if let auth = author {
                setUpAuthor(author: auth)
            }
        }
    }
    var didSetAuthor: (() -> Void)?
    func setUpAuthor(author: Author) {
        didSetAuthor?()
    }
}


//
// class EditProfileViewModel {
//    var author: Author? {
//        didSet {
//            updateData()
//        }
//    }
//
//    var onProfileUpdated: (() -> Void)?
//    var onError: ((String) -> Void)?
//
//    func updateData() {
//        onProfileUpdated?()
//    }
//
//    func saveProfile(name: String, littleWords: String, image: UIImage?) {
//        guard let name = name, !name.isEmpty else {
//            onError?("名字不能為空")
//            return
//        }
//        // Implement image upload and profile update logic
//    }
//
//    func deleteAccount() {
//        // Implement account deletion logic
//    }
//
//    func logout() {
//        do {
//            try Auth.auth().signOut()
//            onProfileUpdated?() 
//        } catch let signOutError as NSError {
//            onError?(signOutError.localizedDescription)
//        }
//    }
//
// }
