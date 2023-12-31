//
//  RelationshipListViewModel.swift
//  MyCloset
//
//  Created by 賀華 on 2023/12/18.
//

 import RxSwift
 import RxCocoa

 class RelationshipListViewModel {
    let buttonTitle = ["Following", "Followers", "Block List"]
    let backButtonImage = UIImage(systemName: "chevron.backward.circle")
    private let disposeBag = DisposeBag()
    private let friendsRelay = BehaviorRelay<[Author]>(value: [])
    let likeAmount: Observable<Int>

    init() {
        likeAmount = friendsRelay.map { $0.count }
        FirebaseStorageManager.shared.getAuth { author in
            self.fetchData(friendList: author.following ?? [])
        }
    }

    func fetchData(friendList: [String]) {
        FirebaseStorageManager.shared.fetchName(ids: friendList) { [weak self] names in
            self?.friendsRelay.accept(names)
        }
    }

    var friends: Observable<[Author]> {
        return friendsRelay.asObservable()
    }
 }

// class RelationshipListViewModel {
//    var buttonTitle = ["Following", "Followers", "Block List"]
//    var backImageName = "chevron.backward.circle"
//    var likeAmount: Int = 0
//    var dataChanged: (() -> Void)?
//
//    private var friends: [Author] = [] {
//        didSet {
//            self.updateLikesAmount()
//        }
//    }
//
//    func fetchData(friendList: [String]) {
//        FirebaseStorageManager.shared.fetchName(ids: friendList) { [weak self] names in
//            self?.friends = names
//            self?.dataChanged?()
//        }
//    }
//
//    func getFriend(at index: Int) -> Author {
//        return friends[index]
//    }
//
//    var numberOfFriends: Int {
//        return friends.count
//    }
//
//    private func updateLikesAmount() {
//        likeAmount = friends.count
//    }
// }
