//
//  Firebase.swift
//  MyCloset
//
//  Created by 賀華 on 2023/11/16.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

struct Article: Codable {
    let author: Author
    let content: String
    let createdTime: Double
    let id: String
    let imageURL: String
    let productList: [Product]
    let position: [Position]
    let like: Int
    let whoLiked: [String]
    let comment: [Comment]
}

struct Comment: Codable {
    let comment: String
    let authName: String
    let authId: String
    let createdTime: Double
}

struct Author: Codable {
    let email: String
    let id: String
    let name: String
    let image: String?
    let height: String?
    let weight: String?
    let privateOrNot: Bool?
    let littleWords: String?
    let following: [String]?
    let followers: [String]?
    let pending: [String]?
    let post: [Post]?
    let saved: [Post]?
    let notification: [NotificationStruct]?
    let notificationNotSeen: Int?
    let blockedUsers: [String]?
    let blockedByUsers: [String]?
}

struct NotificationStruct: Codable {
    let name: String
    let postId: String?
    let authId: String?
    let comment: String
    let createdTime: Double
    let seen: Bool
}

enum NotifyWord: String {
    case like = "liked your post"
    case comment = "leave a comment on your post"
    case reject = "rejected your follow request"
    case accept = "accepted your follow request, you can see their post on your home page now"
    case deleteFriend = "doesn't wants to follow you anymore, what a shame :("
    case myAcception = "started to follow you"
}

struct Post: Codable {
    let id: String
    let image: String
    let createdTime: Double
}

struct Position: Codable {
    let xPosition: Double
    let yPosition: Double
    enum CodingKeys: String, CodingKey {
            case xPosition = "x"
            case yPosition = "y"
        }
}

struct Product: Codable {
    let productName: String
    let productStore: String
    let productPrice: String
    let productComment: String
}

// auth
class FirebaseStorageManager {
    static let shared = FirebaseStorageManager()
    let firebaseDb = Firestore.firestore()
    var isFirstLoad = true
    var currentNotificationCount: Int?
    var currentPendingCount: Int?
    var currentNotificationNotSeen: Int?
    private init() {}
    func getAuth(completion: @escaping (Author) -> Void) {
        let auth = firebaseDb.collection("auth").document(Auth.auth().currentUser?.uid ?? "")
        auth.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                do {
                    if let document = document, document.exists, let data = document.data() {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let decoder = JSONDecoder()
                        let author = try decoder.decode(Author.self, from: jsonData)
                        completion(author)
                    } else {
                        print("Document does not exist")
                    }
                } catch {
                    print("Error decoding author data: \(error)")
                }
            }
        }
    }
    
    func getSpecificAuth(id: String, completion: @escaping (Result<Author, Error>) -> Void) {
        let auth = firebaseDb.collection("auth").document(id)
        auth.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(.failure(error))
            } else {
                do {
                    if let document = document, document.exists, let data = document.data() {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let decoder = JSONDecoder()
                        let author = try decoder.decode(Author.self, from: jsonData)
                        completion(.success(author))
                    } else {
                        print("Document does not exist")
                        let notExistError = NSError(domain: "YourDomain", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
                        completion(.failure(notExistError))
                    }
                } catch {
                    print("Error decoding author data: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }

    
    func addAuth(uid: String, author: Author, completion: @escaping (Result<Void, Error>) -> Void) {
        let auth = firebaseDb.collection("auth")
        let document = auth.document(uid)
        let authorData = [
            "email": author.email,
            "id": author.id,
            "name": author.name,
            "image": "",
            "height": "",
            "weight": "",
            "privateOrnot": false,
            "littleWords": "",
            "following": [author.id],
            "followers": [],
            "post": [],
            "saved": [],
            "pending": []
        ] as [String: Any]
        
        document.setData(authorData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateAuth(image: String, name: String, littleWords: String, weight: String, height: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1,
                               userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        firebaseDb.collection("auth").document(currentUserID).updateData([
            "name": name,
            "littleWords": littleWords,
            "weight": weight,
            "height": height,
            "image": image
        ]) { error in
            completion(error)
        }
    }
    
    func getAuthorNameById(authorId: String, completion: @escaping (String?) -> Void) {
        let authDocument = firebaseDb.collection("auth").document(authorId)
        
        authDocument.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                do {
                    if let document = document, document.exists, let data = document.data() {
                        guard let name = data["name"] as? String else {
                            print("Name not found in document data")
                            completion(nil)
                            return
                        }
                        completion(name)
                    } else {
                        print("Document does not exist")
                        completion(nil)
                    }
                } 
            }
        }
    }
}

// post
extension FirebaseStorageManager {
    func fetchData(completion: @escaping ([Article]) -> Void) {
        var blocked: [String] = []
        getAuth { author in
            blocked += author.blockedUsers ?? []
            blocked += author.blockedByUsers ?? []
        }
        let articlesCollection = firebaseDb.collection("articles")
        articlesCollection.order(by: "like", descending: true).getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("Error getting documents: \(error!)")
                completion([])
                return
            }
            
            var articles: [Article] = []
            
            do {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decoder = JSONDecoder()
                    let article = try decoder.decode(Article.self, from: jsonData)
                    if !blocked.contains(article.author.id) {
                        articles.append(article)
                    }
                }
                completion(articles)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }
    }
    
    func fetchSpecificData(id: String, completion: @escaping (Article) -> Void) {
        let auth = firebaseDb.collection("articles").document(id)
        auth.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                do {
                    if let document = document, document.exists, let data = document.data() {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let decoder = JSONDecoder()
                        let article = try decoder.decode(Article.self, from: jsonData)
                        completion(article)
                    } else {
                        print("Document does not exist")
                    }
                } catch {
                    print("Error decoding author data: \(error)")
                }
            }
        }
    }
    
    func getFollowingArticles(completion: @escaping ([Article]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        firebaseDb.collection("auth").document(currentUserID).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion([])
                return
            }
            
            guard let following = document?.data()?["following"] as? [String] else {
                print("Following list not found.")
                completion([])
                return
            }
            var articles: [Article] = []
            
            let dispatchGroup = DispatchGroup()
            
            for followerID in following {
                dispatchGroup.enter()
                
                self.firebaseDb.collection("articles")
                    .whereField("author.id", isEqualTo: followerID)
                // .whereField("createdTime", isGreaterThan: (Date().timeIntervalSince1970 - (30 * 24 * 60 * 60)))
                    .getDocuments { (querySnapshot, error) in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        guard error == nil else {
                            print("Error getting documents for \(followerID): \(error!)")
                            return
                        }
                        
                        guard let querySnapshot = querySnapshot else {
                            print("Query snapshot is nil for \(followerID)")
                            return
                        }
                        
                        do {
                            for document in querySnapshot.documents {
                                let data = document.data()
                                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                                let decoder = JSONDecoder()
                                let article = try decoder.decode(Article.self, from: jsonData)
                                articles.append(article)
                            }
                        } catch {
                            print("Error decoding JSON for \(followerID): \(error)")
                        }
                    }
            }
            
            dispatchGroup.notify(queue: .main) {
                
                let sortedArticles = articles.sorted(by: { $0.createdTime > $1.createdTime })
                completion(sortedArticles)
            }
        }
    }
    
    private func parsePositions(_ positionsData: [[String: Double]]) -> [Position] {
        var positions: [Position] = []
        for positionData in positionsData {
            if let xPosition = positionData["x"],
               let yPosition = positionData["y"] {
                let position = Position(xPosition: xPosition, yPosition: yPosition)
                positions.append(position)
            }
        }
        return positions
    }
    
    private func parseProducts(_ productsData: [[String: String]]) -> [Product] {
        var products: [Product] = []
        for productData in productsData {
            let productName = productData["productName"] ?? ""
            let productStore = productData["productStore"] ?? ""
            let productPrice = productData["productPrice"] ?? ""
            let productComment = productData["productComment"] ?? ""
            
            let product = Product(productName: productName,
                                  productStore: productStore,
                                  productPrice: productPrice,
                                  productComment: productComment)
            
            products.append(product)
        }
        return products
    }
    
    func addArticle(auth: Author,imageURL: String, content: String, positions: [CGPoint] , productList: [Product], completion: @escaping (Error?) -> Void) {
        let convertedPositions: [[String: CGFloat]] = positions.map { point in
            return ["x": point.x, "y": point.y]
        }
        let convertedProductList: [[String: String]] = productList.map { product in
            return ["productName": product.productName, "productStore": product.productStore,
                    "productPrice": product.productPrice, "productComment": product.productComment]
        }
        
        let articles = firebaseDb.collection("articles")
        let document = articles.document()
        let author = [
            "email": auth.email,
            "id": auth.id,
            "name": auth.name,
            "image": auth.image
        ]
        let data: [String: Any] = [
            "author": author,
            "imageURL": imageURL,
            "position": convertedPositions,
            "content": content,
            "productList": convertedProductList,
            "createdTime": Date().timeIntervalSince1970,
            "id": document.documentID,
            "like": 0,
            "whoLiked": [],
            "comment": []
        ]
        document.setData(data) { error in
            completion(error)
        }
        
        let post: [String: Any] = [
            "id": document.documentID,
            "image": imageURL,
            "createdTime": Date().timeIntervalSince1970
        ]
        firebaseDb.collection("auth").document(auth.id).updateData([
            "post": FieldValue.arrayUnion([post])
        ])
    }
    
    func uploadImageAndGetURL(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images").child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        completion(.success(downloadURL))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// friend
extension FirebaseStorageManager {
    func searchFriends(query: String, completion: @escaping ([Author]) -> Void) {
        var blocked: [String] = []
        getAuth { author in
            blocked += author.blockedUsers ?? []
            blocked += author.blockedByUsers ?? []
        }
        let lowercaseQuery = query.lowercased()
        firebaseDb.collection("auth")
            .whereField("name", isGreaterThanOrEqualTo: lowercaseQuery)
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
        
//
//        updateNotificationArray(authorId: authorID, postId: "", updatedComment: .tapAccept, originComment: .friendRequest) { error in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                print("update success")
//            }
//        }
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
//        updateNotificationArray(authorId: authorID, postId: "", updatedComment: .tapReject, originComment: .friendRequest) { error in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                print("update success")
//            }
//        }
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
