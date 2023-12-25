//
//  Model.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/22.
//

import Foundation
// Firebase
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
    let dollImageURL: String?
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
    var productName: String
    var productStore: String
    var productPrice: String
    var productComment: String
}

// CoreData
struct ClothesStruct {
    var category: String?
    var subcategory: String?
    var item: String?
    var price: String?
    var store: String?
    var content: String?
    var image: Data?
    var cloth: [String]?
    var clothB: [String]?
    var color: [CGFloat]?
    var draw: Data?
}

struct HairStruct {
    var hair: [String]
    var hairB: [String]
    var color: [CGFloat]
}
