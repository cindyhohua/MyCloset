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
                        print("Document data: \(data)")
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
                print(articles)
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
                        print("Specific document data: \(data)")
                    } else {
                        print("Document does not exist")
                    }
                } catch {
                    print("Error decoding author data: \(error)")
                }
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
        ]
        document.setData(data) { error in
            completion(error)
        }
        
        let post : [String: Any] = [
            "id" : document.documentID,
            "image" : imageURL,
            "createdTime": Date().timeIntervalSince1970
        ]
        print(post)
        db.collection("auth").document(auth.id).updateData([
            "post": FieldValue.arrayUnion([post])
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
            "following": [],
            "followers": [],
            "post": [],
            "saved": []
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
