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

class FirebaseStorageManager {

    static let shared = FirebaseStorageManager()
    
    private let db = Firestore.firestore()

    private init() {}
    var imageURL: String = ""
    func fetchData(completion: @escaping (String) -> Void) { //completion: @escaping ([Article]) -> Void
//        var articles: [Article] = []

        let articlesCollection = db.collection("articles")
        articlesCollection.order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let imageURL = data["imageURL"] as? String ?? ""
                    self.imageURL = imageURL
                    print(imageURL)
//                        articles.append(article)
                    }
                }
            completion(self.imageURL)
            }
        }
    
    
    func addArticle(imageURL: String, content: String, positions: [CGPoint] , category: String, completion: @escaping (Error?) -> Void) {
        let convertedPositions: [[String: CGFloat]] = positions.map { point in
            return ["x": point.x, "y": point.y]
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
            "createdTime": Date().timeIntervalSince1970,
            "id": document.documentID,
        ]
        document.setData(data) { error in
            completion(error)
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
                        print("qqqqqqImageURL",downloadURL)
                        completion(.success(downloadURL))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
