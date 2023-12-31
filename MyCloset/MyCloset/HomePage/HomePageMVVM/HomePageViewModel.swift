//
//  HomePageViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/31.
//
import FirebaseMessaging

class HomePageViewModel {
    var articles: [Article] = []
    
    func updateFMC() {
        Messaging.messaging().token { token, error in
            Messaging.messaging().token { token, error in
              if let error = error {
                print("Error fetching FCM registration token: \(error)")
              } else if let token = token {
                print("FCM registration token: \(token)")
                  FirebaseStorageManager.shared.addFMCFieldToAuthDocument(fmc: token)
              }
            }
        }
    }
    
    func getFollowingArticle(complete: @escaping (() -> Void)) {
        self.articles = []
        FirebaseStorageManager.shared.getFollowingArticles { articles in
            self.articles = articles
            complete()
        }
    }
    
    func fetchNotSeenNotifications(completion: @escaping (Int) -> Void) {
        FirebaseStorageManager.shared.fetchNotSeen { notSeenNumber in
            completion(notSeenNumber)
        }
    }
}
