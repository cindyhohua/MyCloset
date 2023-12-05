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

// notification
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
                
                let updatedData: [String: Any] = [
                    "notification": FieldValue.arrayUnion([commentNotify]),
                    "notificationNotSeen": FieldValue.increment(Int64(1))
                ]
                
                self.firebaseDb.collection("auth").document(authorId).updateData(updatedData) { error in
                    completion(error)
                }
            } else {
                let error = NSError(domain: "YourAppErrorDomain", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Error retrieving author name"])
                completion(error)
            }
        }
    }
    
    func sendNotificationMyAcception(authorId: String, postId: String, notifyType: NotifyWord, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
             userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        getAuthorNameById(authorId: authorId) { name in
            if let name = name {
                let commentNotify: [String: Any] = [
                    "name": name,
                    "postId": postId,
                    "authId": authorId,
                    "comment": notifyType.rawValue,
                    "seen": false,
                    "createdTime": Date().timeIntervalSince1970
                ]
                
                let updatedData: [String: Any] = [
                    "notification": FieldValue.arrayUnion([commentNotify])
                ]
                self.firebaseDb.collection("auth").document(currentUserID).updateData(updatedData) { error in
                    completion(error)
                }
            } else {
                let error = NSError(
                    domain: "YourAppErrorDomain", code: -1,
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
                    
                    notifications.sort { $0.createdTime > $1.createdTime }
                    
                    completion(notifications, nil)
                } else {
                    completion([], nil)
                }
            }
        }
    }
    
    func startListeningForAuthChanges() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "YourAppErrorDomain", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            return
        }
        let docRef = firebaseDb.collection("auth").document(currentUserID)
        
        docRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            guard document.exists else {
                print("Document does not exist")
                return
            }
            
            if self.isFirstLoad == true {
                if let notifications = document["notification"] as? [[String: Any]],
                   let pendingRequests = document["pending"] as? [String],
                   let notificationNotSeen = document["notificationNotSeen"] as? Int {
                    self.currentNotificationCount = notifications.count
                    self.currentPendingCount = pendingRequests.count
                    self.currentNotificationNotSeen = notificationNotSeen
                    self.isFirstLoad = false
                }
            }
            
            if let oldNotificationCount = self.currentNotificationCount,
               let oldPendingCount = self.currentPendingCount,
               let oldNotificationNotSeen = self.currentNotificationNotSeen,
               let notifications = document["notification"] as? [[String: Any]],
               let pendingRequests = document["pending"] as? [String],
               let newNotificationNotSeen = document["notificationNotSeen"] as? Int,
               !self.isFirstLoad {
                
                let newNotificationCount = notifications.count
                let newPendingCount = pendingRequests.count
                
                if newNotificationCount > oldNotificationCount {
                    print("Notification change:", notifications.last)
//                    self.handleNotificationsChange(notifications: notifications)
                } else if newPendingCount > oldPendingCount {
                    print("Pending requests change:", pendingRequests.last)
//                    self.handlePendingRequestsChange(pendingRequests: pendingRequests)
                }
                
                if newNotificationNotSeen != oldNotificationNotSeen {
                    print("NotificationNotSeen change:", newNotificationNotSeen)
                    NotificationCenter.default.post(name: Notification.Name("NotificationUpdate"), object: nil)
                }
                self.currentNotificationCount = newNotificationCount
                self.currentPendingCount = newPendingCount
                self.currentNotificationNotSeen = newNotificationNotSeen
            } else {
                self.isFirstLoad = false
            }
        }
    }

    func handleNotificationsChange(notifications: [[String: Any]]) {
        if let name = notifications.last?["name"] as? String, let comment = notifications.last?["comment"] as? String {
            displayLocalNotification(contentString: name + " " + comment)
        }
    }

    func handlePendingRequestsChange(pendingRequests: [String]) {
        getAuthorNameById(authorId: pendingRequests.last ?? "") { name in
            self.displayLocalNotification(contentString: (name ?? "") + " requested to follow you")
        }
    }

    func displayLocalNotification(contentString: String) {
        let content = UNMutableNotificationContent()
            content.title = "MyCloset"
            content.body = contentString

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error displaying notification: \(error)")
                }
            }
        }
}

// badge
extension FirebaseStorageManager {
    func fetchNotSeen(completion: @escaping (Int) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(0)
            return
        }
        firebaseDb.collection("auth").document(currentUserID).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(0)
                return
            }

            guard let document = document, document.exists,
                  let data = document.data(),
                  let notificationNotSeen = data["notificationNotSeen"] as? Int else {
                completion(0)
                return
            }
            completion(notificationNotSeen)
        }
    }
    
    func resetNotificationNotSeen(completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "YourAppErrorDomain", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            completion(error)
            return
        }
        
        let updatedData: [String: Any] = [
            "notificationNotSeen": 0
        ]
        
        firebaseDb.collection("auth").document(currentUserID).updateData(updatedData) { error in
            completion(error)
        }
    }
    
    func addFMCFieldToAuthDocument(fmc: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let authCollection = firebaseDb.collection("auth")
        let userDocument = authCollection.document(currentUserID)
        
        // 更新 "fmc" 欄位
        userDocument.updateData(["fmc": fmc]) { error in
            if let error = error {
                print("Error updating fmc field: \(error.localizedDescription)")
            } else {
                print("fmc field updated successfully")
            }
        }
    }
}

// delete account
extension FirebaseStorageManager {
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
        getAuth { author in
            var postID: [String] = []
            guard let posts = author.post else {
                return
            }
            for authorPost in posts {
                postID.append(authorPost.id)
            }
            self.deletePost(for: postID)
            self.deleteFriend(usersWhoFollowHim: author.followers, usersWhoHasBeenFollowed: author.following)
            self.deleteMyself()
            completion(.success(()))
        }
    }
    
    func deletePost(for postIDs: [String]?) {
        guard let postIDs = postIDs else {
            return
        }
        
        let postsCollection = firebaseDb.collection("articles")
        
        for postID in postIDs {
            postsCollection.document(postID).delete { error in
                if let error = error {
                    print("Error deleting post \(postID): \(error)")
                }
            }
        }
    }
    
    func deleteFriend(usersWhoFollowHim: [String]?, usersWhoHasBeenFollowed: [String]?) {
        guard let followers = usersWhoFollowHim, let following = usersWhoHasBeenFollowed else {
            return
        }
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let authCollection = firebaseDb.collection("auth")
        
        for user in followers {
            authCollection.document(user).updateData([
                "following": FieldValue.arrayRemove([currentUserID])
            ]) { error in
                if let error = error {
                    print("Error updating following list for user \(currentUserID): \(error)")
                }
            }
        }
        
        for user in followers {
            authCollection.document(user).updateData([
                "followers": FieldValue.arrayRemove([currentUserID])
            ]) { error in
                if let error = error {
                    print("Error updating followers list for user \(user): \(error)")
                }
            }
        }
    }
    
    func deleteMyself() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).delete { error in
            if let error = error {
                print("Error deleting user \(currentUserID): \(error)")
            }
        }
    }
}
