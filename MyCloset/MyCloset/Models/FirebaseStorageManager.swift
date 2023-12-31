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
                        let notExistError = NSError(
                            domain: "YourDomain", code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])
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
    
    func updateAuth(
        image: String, name: String, littleWords: String,
        weight: String, height: String, completion: @escaping (Error?) -> Void) {
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
    func searchStoreName(store: String, completion: @escaping ([Article]) -> Void) {
        fetchData { articles in
            var articleStore: [Article] = []
            for article in articles {
                for list in article.productList where list.productStore.lowercased() == store.lowercased() {
                    articleStore.append(article)
                    break
                }
            }
            completion(articleStore)
        }
    }
    
    func fetchDollData(completion: @escaping ([Article]) -> Void) {
        var blocked: [String] = []
        getAuth { author in
            blocked += author.blockedUsers ?? []
            blocked += author.blockedByUsers ?? []
        }
        let articlesCollection = firebaseDb.collection("articles")
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
                    if !blocked.contains(article.author.id), let urlString = article.dollImageURL {
                        if urlString != "" {
                            articles.append(article)
                        }
                    }
                }
                completion(articles)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }
    }
    
    func fetchLatestData(completion: @escaping ([Article]) -> Void) {
        var blocked: [String] = []
        getAuth { author in
            blocked += author.blockedUsers ?? []
            blocked += author.blockedByUsers ?? []
        }
        let articlesCollection = firebaseDb.collection("articles")
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
    
    func addArticle(
        auth: Author, imageURL: String, content: String, positions: [CGPoint],
        productList: [Product], dollImageURL: String, completion: @escaping (Error?) -> Void) {
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
            "comment": [],
            "dollImageURL": dollImageURL
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
