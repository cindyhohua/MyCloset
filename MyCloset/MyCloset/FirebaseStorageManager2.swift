//
//  FirebaseStorageManager2.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/2.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
// like, saved, comment
extension FirebaseStorageManager {
    func fetchLike(postId: String, completion: @escaping (Result<(likeCount: Int, isLiked: Bool), Error>) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let postRef = firebaseDb.collection("articles").document(postId)
        postRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                let isLiked = (document.data()?["whoLiked"] as? [String] ?? []).contains(currentUserID)
                let likeCount = document.data()?["like"] as? Int ?? 0
                
                completion(.success((likeCount, isLiked)))
            } else {
                completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    func savePost(postId: String, imageURL: String, time: Double, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let post: [String: Any] = [
            "id": postId,
            "image": imageURL,
            "createdTime": time
        ]
        let userRef = firebaseDb.collection("auth").document(currentUserID)
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                if let savedPosts = document.data()?["saved"] as? [[String: Any]],
                   savedPosts.contains(where: { $0["id"] as? String == postId }) {
                    userRef.updateData([
                        "saved": FieldValue.arrayRemove([post])
                    ]) { error in
                        completion(error)
                    }
                } else {
                    userRef.updateData([
                        "saved": FieldValue.arrayUnion([post])
                    ]) { error in
                        completion(error)
                    }
                }
            } else {
                completion(NSError(domain: "YourAppErrorDomain", code: -1,
                                   userInfo: [NSLocalizedDescriptionKey: "User document does not exist"]))
            }
        }
    }

    func toggleLike(postId: String, authorId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let postRef = firebaseDb.collection("articles").document(postId)
        postRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                let isLiked = document.data()?["whoLiked"] as? [String] ?? []
                
                if isLiked.contains(currentUserID) {
                    self.unlikePost(postRef: postRef, currentUserID: currentUserID, completion: completion)
                } else {
                    self.likePost(postRef: postRef, currentUserID: currentUserID,
                                  authorId: authorId, postId: postId, completion: completion)
                }
            } else {
                completion(NSError(domain: "YourAppErrorDomain", code: -1,
                                   userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
            }
        }
    }
    
    func likePost(postRef: DocumentReference, currentUserID: String, authorId: String, postId: String, completion: @escaping (Error?) -> Void) {
        postRef.updateData([
            "like": FieldValue.increment(Int64(1)),
            "whoLiked": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            completion(error)
        }
        
        if currentUserID != authorId {
            sendNotification(authorId: authorId, postId: postId, notifyType: .like) { error in
                if let error = error {
                    print("Error sending notification: \(error)")
                } else {
                    print("Notification sent successfully")
                }
            }
        }
    }
    
    func unlikePost(postRef: DocumentReference, currentUserID: String, completion: @escaping (Error?) -> Void) {
        postRef.updateData([
            "like": FieldValue.increment(Int64(-1)),
            "whoLiked": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            completion(error)
        }
        
    }

    func addComment(postId: String, comment: String, posterId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let postRef = firebaseDb.collection("articles").document(postId)

        getAuth { author in
            let commentData: [String: Any] = [
                "comment": comment,
                "authName": author.name,
                "authId": currentUserID,
                "createdTime": Date().timeIntervalSince1970
            ]
            postRef.updateData([
                "comment": FieldValue.arrayUnion([commentData])
            ]) { error in
                completion(error)
            }
            if currentUserID != posterId {
                self.sendNotification(authorId: posterId, postId: postId, notifyType: .comment) { error in
                    if let error = error {
                        print("Error sending notification: \(error)")
                    } else {
                        print("Notification sent successfully")
                    }
                }
            }
        }
    }
}

extension FirebaseStorageManager {
    func sendNotification(authorId: String, postId: String, notifyType: NotifyWord, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        getAuthorNameById(authorId: currentUserID) { name in
            if let name = name {
                let commentNotify: [String: Any] = [
                    "name": name,
                    "postId": postId,
                    "authId": currentUserID,
                    "comment": notifyType.rawValue,
                    "seen": false,
                    "createdTime": Date().timeIntervalSince1970
                ]
                self.firebaseDb.collection("auth").document(authorId).updateData([
                    "notification": FieldValue.arrayUnion([commentNotify])
                ]) { error in
                    completion(error)
                }
            } else {
                let error = NSError(domain: "YourAppErrorDomain", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Error retrieving author name"])
                completion(error)
            }
        }
    }
    
    func fetchNotifications(completion: @escaping ([NotificationStruct]?, Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "YourAppErrorDomain", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            completion(nil, error)
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            do {
                if let document = document, document.exists, let data = document.data(),
                   let notificationsData = data["notification"] as? [[String: Any]] {
                    
                    var notifications = [NotificationStruct]()
                    
                    for notificationData in notificationsData {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: notificationData),
                           let notification = try? JSONDecoder().decode(NotificationStruct.self, from: jsonData) {
                            notifications.append(notification)
                        }
                    }
                    
                    // 倒序排列
                    notifications.sort { $0.createdTime > $1.createdTime }
                    
                    completion(notifications, nil)
                } else {
                    completion([], nil)  // 沒有通知
                }
            } catch {
                completion(nil, error)
            }
        }
    }
    

    
    //    func updateNotificationArray(authorId: String, postId: String, updatedComment: NotifyWord, originComment: NotifyWord, completion: @escaping (Error?) -> Void) {
    //        let documentReference = firebaseDb.collection("auth").document(authorId)
    //        guard let currentUserID = Auth.auth().currentUser?.uid else {
    //            completion(NSError(domain: "YourAppErrorDomain", code: -1,
    //                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
    //            return
    //        }
    //        documentReference.getDocument { (document, error) in
    //            if let error = error {
    //                completion(error)
    //                return
    //            }
    //            do {
    //                var currentNotificationArray = document?.get("notification") as? [[String: Any]] ?? []
    //
    //                if let index = currentNotificationArray.firstIndex(where: { $0["comment"] as? String == originComment.rawValue && $0["authId"] as? String == currentUserID }) {
    //                    currentNotificationArray[index]["comment"] = updatedComment.rawValue
    //                }
    //
    //                documentReference.updateData(["notification": currentNotificationArray]) { error in
    //                    completion(error)
    //                }
    //            }
    //        }
    //    }
}
