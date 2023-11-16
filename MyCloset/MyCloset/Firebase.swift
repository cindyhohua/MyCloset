//
//  Firebase.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

//import Foundation
//import UIKit
//import Firebase
//
//class FirebaseStorageManager {
//
//    static let shared = FirebaseStorageManager()
//
//    private init() {}
//
//    func uploadImageAndGetURL(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
//            return
//        }
//
//        let filename = UUID().uuidString // 使用唯一的檔案名稱
//        let storageRef = Storage.storage().reference().child("images").child(filename)
//
//        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                storageRef.downloadURL { (url, error) in
//                    if let downloadURL = url {
//                        completion(.success(downloadURL))
//                    } else if let error = error {
//                        completion(.failure(error))
//                    }
//                }
//            }
//        }
//    }
//}
