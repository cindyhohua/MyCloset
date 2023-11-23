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

struct Article {
    let author: Author
    let content: String
    let createdTime: Double
    let id: String
    let imageURL: String
    let productList: [Product]
    let positions: [Position]
}
struct Author {
    let email: String
    let id: String
    let name: String
}

struct Position {
    let x: Double
    let y: Double
}

struct Product {
    let productName: String
    let productStore: String
    let productPrice: String
    let productComment: String
}

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()
    
    private let db = Firestore.firestore()

    private init() {}

    func fetchData(completion: @escaping ([Article]) -> Void) {
            let articlesCollection = db.collection("articles")
            articlesCollection.order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion([])
                } else {
                    var articles: [Article] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let imageURL = data["imageURL"] as? String ?? ""
                        let dataAuthor = data["author"] as? [String: String]
                        let author = Author(email: dataAuthor?["email"] as? String ?? "",
                                            id: dataAuthor?["id"] as? String ?? "",
                                            name: dataAuthor?["name"] as? String ?? "")
                        
                        let content = data["content"] as? String ?? ""
                        let createdTime = data["createdTime"] as? Double ?? 0.0
                        let id = document.documentID
                        let positions = self.parsePositions(data["position"] as? [[String: Double]] ?? [])
                        let productList = self.parseProducts(data["productList"] as? [[String: String]] ?? [])
                        
                        let article = Article(author: author,
                                              content: content,
                                              createdTime: createdTime,
                                              id: id,
                                              imageURL: imageURL,
                                              productList: productList,
                                              positions: positions)
                        
                        articles.append(article)
                    }
                    completion(articles)
                }
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
    
    
    func addArticle(imageURL: String, content: String, positions: [CGPoint] , productList: [Product], completion: @escaping (Error?) -> Void) {
        let convertedPositions: [[String: CGFloat]] = positions.map { point in
            return ["x": point.x, "y": point.y]
        }
        let convertedProductList: [[String:String]] = productList.map { product in
            return ["productName": product.productName, "productStore": product.productStore, "productPrice": product.productPrice, "productComment": product.productComment]
        }
        
        let articles = db.collection("articles")
        let document = articles.document()
        let author = [
            "email": "cindyhohua.tw",
            "id": "cindyhohuahahaha",
            "name": "白花油點馬啾"
        ]
        let data: [String: Any] = [
            "author": author,
            "imageURL": imageURL,
            "position": convertedPositions,
            "content": content,
            "productList": convertedProductList,
            "createdTime": Date().timeIntervalSince1970,
            "id": document.documentID,
        ]
        document.setData(data) { error in
            completion(error)
        }
    }
    
    func addAuth(uid: String, author: Author, completion: @escaping (Result<Void, Error>) -> Void) {
        let auth = db.collection("auth")
        let document = auth.document(uid)
        let authorData = [
            "email": author.email,
            "id": author.id,
            "name": author.name
        ]

        document.setData(authorData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    
    func uploadImageAndGetURL(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
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
}
