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
                "createdTime": createdTime ?? 0,
                "id": postId,
                "image": imageURL ?? ""
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

extension FirebaseStorageManager {
    func searchFriends(query: String, completion: @escaping ([Author]) -> Void) {
        var blocked: [String] = []
        getAuth { author in
            blocked += author.blockedUsers ?? []
            blocked += author.blockedByUsers ?? []
        }
        firebaseDb.collection("auth")
            .whereField("name", isGreaterThanOrEqualTo: query)
            .whereField("name", isLessThan: query + "z")
            .getDocuments { (querySnapshot, error) in
                guard error == nil else {
                    print("Error getting documents: \(error!)")
                    completion([])
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("Query snapshot is nil.")
                    completion([])
                    return
                }
                
                let searchResults: [Author] = querySnapshot.documents.compactMap { document in
                    do {
                        let data = document.data()
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                        let decoder = JSONDecoder()
                        let user =  try decoder.decode(Author.self, from: jsonData)
                        if !blocked.contains(user.id) {
                            return user
                        } else {
                            return nil
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        return nil
                    }
                }
                completion(searchResults)
            }
    }
    
    func sendFriendRequest(toUserID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firebaseDb.collection("auth").document(toUserID).updateData([
            "pending": FieldValue.arrayUnion([currentUserID]),
            "notificationNotSeen": FieldValue.increment(Int64(1))
        ]) { error in
            completion(error)
        }
    }
    
    func cancelFriendRequest(toUserID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firebaseDb.collection("auth").document(toUserID).updateData([
            "pending": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            completion(error)
        }
    }
    
    func fetchPendingRequests(completion: @escaping ([Author]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot, document.exists,
                  let pendingRequests = document.data()?["pending"] as? [String] else {
                completion([])
                return
            }
            
            var pendingAuthors: [Author] = []
            
            let dispatchGroup = DispatchGroup()
            
            for pendingID in pendingRequests {
                dispatchGroup.enter()
                
                self.getSpecificAuth(id: pendingID) { result in
                    switch result {
                    case .success(let author):
                        pendingAuthors.append(author)
                        dispatchGroup.leave()
                    case .failure(let error):
                        print(error)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(pendingAuthors)
            }
        }
    }
    
    func fetchName(ids: [String], completion: @escaping ([Author]) -> Void) {
        var pendingAuthorsNames: [Author] = []
        
        let dispatchGroup = DispatchGroup()
        
        for pendingID in ids {
            dispatchGroup.enter()
            print(pendingID)
            
            getSpecificAuth(id: pendingID) { result in
                switch result {
                case .success(let author):
                    pendingAuthorsNames.append(author)
                    print(author.name)
                case .failure(let error):
                    print("Error fetching author: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(pendingAuthorsNames)
            print(pendingAuthorsNames)
        }
    }
    
    func acceptFriendRequest(authorID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).updateData([
            "followers": FieldValue.arrayUnion([authorID]),
            "pending": FieldValue.arrayRemove([authorID])
        ]) { error in
            completion(error)
        }
        
        firebaseDb.collection("auth").document(authorID).updateData([
            "following": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            completion(error)
        }
        
        sendNotification(authorId: authorID, postId: "", notifyType: .accept) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Send successfully")
            }
        }
        sendNotificationMyAcception(authorId: authorID, postId: "", notifyType: .myAcception) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Send successfully")
            }
        }
    }
    
    func rejectFriendRequest(authorID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).updateData([
            "pending": FieldValue.arrayRemove([authorID])
        ]) { error in
            completion(error)
        }
        
        sendNotification(authorId: authorID, postId: "", notifyType: .reject) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Send successfully")
            }
        }
    }
    
    func removeFriend(friendID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firebaseDb.collection("auth").document(currentUserID).updateData([
            "following": FieldValue.arrayRemove([friendID])
        ]) { error in
            completion(error)
        }
        
        firebaseDb.collection("auth").document(friendID).updateData([
            "followers": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            completion(error)
        }
        
        sendNotification(authorId: friendID, postId: "", notifyType: .deleteFriend) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Send successfully")
            }
        }
    }
}

