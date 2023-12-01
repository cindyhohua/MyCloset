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
}

struct Post: Codable{
    let id: String
    let image: String
    let createdTime: Double
}

struct Position: Codable {
    let x: Double
    let y: Double
}

struct Product: Codable {
    let productName: String
    let productStore: String
    let productPrice: String
    let productComment: String
}

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()
    
    private let db = Firestore.firestore()

    private init() {}
    
    func getAuth(completion: @escaping (Author) -> Void) {
        let auth = db.collection("auth").document(Auth.auth().currentUser?.uid ?? "")
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
    
    func getSpecificAuth(id:String,completion: @escaping (Author) -> Void) {
        let auth = db.collection("auth").document(id)
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

    
    func fetchData(completion: @escaping ([Article]) -> Void) {
        let articlesCollection = db.collection("articles")

        articlesCollection.order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
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
                    articles.append(article)
                }
                completion(articles)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }
    }
    
    func fetchSpecificData(id: String, completion: @escaping (Article) -> Void) {
        let auth = db.collection("articles").document(id)
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
        db.collection("auth").document(currentUserID).getDocument { (document, error) in
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
                
                self.db.collection("articles")
                    .whereField("author.id", isEqualTo: followerID)
//                    .whereField("createdTime", isGreaterThan: (Date().timeIntervalSince1970 - (30 * 24 * 60 * 60)))
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
    
    func searchFriends(query: String, completion: @escaping ([Author]) -> Void) {
        db.collection("auth")
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
                        return try decoder.decode(Author.self, from: jsonData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        return nil
                    }
                }
                
                completion(searchResults)
            }
    }
    
    private func parsePositions(_ positionsData: [[String: Double]]) -> [Position] {
        var positions: [Position] = []
        for positionData in positionsData {
            if let x = positionData["x"],
               let y = positionData["y"] {
                let position = Position(x: x, y: y)
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
        let convertedProductList: [[String:String]] = productList.map { product in
            return ["productName": product.productName, "productStore": product.productStore, "productPrice": product.productPrice, "productComment": product.productComment]
        }
        
        let articles = db.collection("articles")
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
        
        let post : [String: Any] = [
            "id" : document.documentID,
            "image" : imageURL,
            "createdTime": Date().timeIntervalSince1970
        ]
        db.collection("auth").document(auth.id).updateData([
            "post": FieldValue.arrayUnion([post])
        ])
    }
    
    func savePost(postId: String, imageURL: String, time: Double, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let post : [String: Any] = [
            "id" : postId,
            "image" : imageURL,
            "createdTime": time
        ]
        db.collection("auth").document(currentUserID).updateData([
            "saved": FieldValue.arrayUnion([post])
        ])
    }
    
    func addAuth(uid: String, author: Author, completion: @escaping (Result<Void, Error>) -> Void) {
        let auth = db.collection("auth")
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
        ] as [String : Any]
        
        document.setData(authorData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    func uploadImageAndGetURL(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let filename = UUID().uuidString
        let storageRef = Storage.storage().reference().child("images").child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
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
    
    func updateAuth(image: String, name: String, littleWords: String, weight: String, height: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        db.collection("auth").document(currentUserID).updateData([
            "name": name,
            "littleWords": littleWords,
            "weight": weight,
            "height": height,
            "image": image
        ]) { error in
            completion(error)
        }
    }
    
    func sendFriendRequest(toUserID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("auth").document(toUserID).updateData([
            "pending": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            completion(error)
        }
    }
    
    func cancelFriendRequest(toUserID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("auth").document(toUserID).updateData([
            "pending": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            completion(error)
        }
    }
    
    func listenForPendingRequests(completion: @escaping ([Author]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        db.collection("auth").document(currentUserID).addSnapshotListener { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion([])
                return
            }
            
            if let pendingRequests = document.data()?["pending"] as? [String] {
                // Fetch details of users who sent pending requests
                var pendingAuthors: [Author] = []
                
                let dispatchGroup = DispatchGroup()
                
                for pendingID in pendingRequests {
                    dispatchGroup.enter()
                    
                    self.getSpecificAuth(id: pendingID) { author in
                        pendingAuthors.append(author)
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(pendingAuthors)
                }
            } else {
                completion([])
            }
        }
    }
    
    func acceptFriendRequest(authorID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("auth").document(currentUserID).updateData([
            "followers": FieldValue.arrayUnion([authorID]),
            "pending": FieldValue.arrayRemove([authorID])
        ]) { error in
            completion(error)
        }
        
        db.collection("auth").document(authorID).updateData([
            "following": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            completion(error)
        }
    }
    
    func rejectFriendRequest(authorID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("auth").document(currentUserID).updateData([
            "pending": FieldValue.arrayRemove([authorID])
        ]) { error in
            completion(error)
        }
    }
    
    func removeFriend(friendID: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("auth").document(currentUserID).updateData([
            "following": FieldValue.arrayRemove([friendID])
        ]) { error in
            completion(error)
        }
        
        db.collection("auth").document(friendID).updateData([
            "followers": FieldValue.arrayRemove([currentUserID])
        ]) { error in
            completion(error)
        }
    }
    
    func fetchLike(postId: String, completion: @escaping (Result<(likeCount: Int, isLiked: Bool), Error>) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let postRef = db.collection("articles").document(postId)
        postRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                let isLiked = (document.data()?["whoLiked"] as? [String] ?? []).contains(currentUserID)
                let likeCount = document.data()?["like"] as? Int ?? 0
                
                completion(.success((likeCount, isLiked)))
            } else {
                completion(.failure(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }

    func toggleLike(postId: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let postRef = db.collection("articles").document(postId)
        postRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                let isLiked = document.data()?["whoLiked"] as? [String] ?? []
                
                if isLiked.contains(currentUserID) {
                    self.unlikePost(postRef: postRef, currentUserID: currentUserID, completion: completion)
                } else {
                    self.likePost(postRef: postRef, currentUserID: currentUserID, completion: completion)
                }
            } else {
                completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
            }
        }
    }
    
    func likePost(postRef: DocumentReference, currentUserID: String, completion: @escaping (Error?) -> Void) {
        postRef.updateData([
            "like": FieldValue.increment(Int64(1)),
            "whoLiked": FieldValue.arrayUnion([currentUserID])
        ]) { error in
            completion(error)
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

    func addComment(postId: String, comment: String, completion: @escaping (Error?) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "YourAppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        let postRef = db.collection("articles").document(postId)

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
        }
    }
}
