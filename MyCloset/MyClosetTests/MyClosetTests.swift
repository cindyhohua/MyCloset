//
//  MyClosetTests.swift
//  MyClosetTests
//
//  Created by 賀華 on 2024/1/1.
//

import XCTest
import Firebase

struct Article: Codable {
    let author: Author
    let content: String
    let createdTime: Double
    let id: String
    let imageURL: String
    let like: Int
    let whoLiked: [String]
    let dollImageURL: String?
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
    let notificationNotSeen: Int?
    let blockedUsers: [String]?
    let blockedByUsers: [String]?
}

final class MyClosetTests: XCTestCase {
    
    func testIdToName() {
        let authorId = "z90YCGM5omWLttNDIfebUi2cYkr2"
        let firebaseDb = Firestore.firestore()
        let authDocument = firebaseDb.collection("auth").document(authorId)
        
        authDocument.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                do {
                    if let document = document, document.exists, let data = document.data() {
                        guard let name = data["name"] as? String else {
                            print("Name not found in document data")
                            return
                        }
                        XCTAssertEqual(name, "Jason")
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    func testFetchSpecificArticle() {
        let id = "aw6wO825HIepafwE26w4uYFmLas1"
        let firebaseDb = Firestore.firestore()
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
                        XCTAssertEqual(article.author.name, "irena0804")
                    } else {
                        print("Document does not exist")
                    }
                } catch {
                    print("Error decoding author data: \(error)")
                }
            }
        }
    }
}
