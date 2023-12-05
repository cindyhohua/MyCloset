//
//  FirebaseStorageManager3.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/5.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

extension FirebaseStorageManager {
    func reportOther(authorId: String, postId: String, reportReason: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(
                NSError(
                    domain: "YourAppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let reportMessage: [String: Any] = [
            "reporterID": currentUserID,
            "postId": postId,
            "authId": authorId,
            "reportContent": reportReason,
            "createdTime": Date().timeIntervalSince1970
        ]
        
        let report = firebaseDb.collection("report")
        let document = report.document()
        
        document.setData(reportMessage) { error in
            completion(error)
        }
    }
    
    func blockOther(authorId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(
                .failure(
                    NSError(
                        domain: "YourAppErrorDomain",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            )
            return
        }
        
        let usersCollection = firebaseDb.collection("auth")
        
        usersCollection.document(currentUserID).updateData([
            "blockedUsers": FieldValue.arrayUnion([authorId]),
            "following": FieldValue.arrayRemove([authorId]),
            "followers": FieldValue.arrayRemove([authorId]),
            "pending": FieldValue.arrayRemove([authorId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        usersCollection.document(authorId).updateData([
            "blockedByUsers": FieldValue.arrayUnion([currentUserID]),
            "following": FieldValue.arrayRemove([currentUserID]),
            "followers": FieldValue.arrayRemove([currentUserID]),
            "pending": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}


