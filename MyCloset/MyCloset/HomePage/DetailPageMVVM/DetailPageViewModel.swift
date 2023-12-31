//
//  DetailPageViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/31.
//

import Foundation

class DetailPageViewModel {
    private var article: Article?
    private var saveOrNot: Bool = false
    
    func configure(with article: Article) {
        self.article = article
    }
    
    func isSaved() -> Bool {
        return saveOrNot
    }
    
    func toggleSave() {
        saveOrNot.toggle()
    }
    
    func deletePost(completion: @escaping (Error?) -> Void) {
        guard let postId = article?.id else {
            completion(nil)
            return
        }
        FirebaseStorageManager.shared.deletePost(postId: postId) { error in
            completion(error)
        }
    }
    
    func reportPost(reason: String, completion: @escaping (Error?) -> Void) {
        guard let authorId = article?.author.id, let postId = article?.id else {
            completion(nil)
            return
        }
        FirebaseStorageManager.shared.reportOther(authorId: authorId, postId: postId, reportReason: reason) { error in
            completion(error)
        }
    }
}

