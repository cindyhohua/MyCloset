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
    
    func unblockOther(authorId: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
            "blockedUsers": FieldValue.arrayRemove([authorId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        usersCollection.document(authorId).updateData([
            "blockedByUsers": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deletePost(postId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(
                NSError(
                    domain: "YourAppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        getCreatedTime(postId: postId) { createdTime, imageURL in
            let authPost = [
                "createdTime": createdTime,
                "id": postId,
                "image": imageURL
            ]
            print(authPost)
            
            let batch = self.firebaseDb.batch()
            
            let userRef = self.firebaseDb.collection("auth").document(currentUserID)
            batch.updateData(["post": FieldValue.arrayRemove([authPost])], forDocument: userRef)
            
            let articleRef = self.firebaseDb.collection("articles").document(postId)
            batch.deleteDocument(articleRef)
            
            batch.commit { error in
                if let error = error {
                    completion(error)
                    print("Error deleting post: \(error.localizedDescription)")
                } else {
                    completion(nil)
                    print("Post deleted successfully")
                }
            }
        }
    }
    
    func getCreatedTime(postId: String, completion: @escaping (Double?, String?) -> Void) {
        getAuth { author in
            let posts = author.post
            if let post = posts?.first(where: { $0.id == postId }) {
                let createdTime = post.createdTime
                let urlString = post.image
                completion(createdTime, urlString)
                print("Found createdTime for post \(postId): \(createdTime)")
            } else {
                completion(nil, nil)
                print("Post with ID \(postId) not found in the array")
            }
        }
    }
}


