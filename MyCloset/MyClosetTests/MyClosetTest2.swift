//
//  MyClosetTest2.swift
//  MyClosetTests
//
//  Created by 賀華 on 2024/1/2.
//

import XCTest
@testable import MyCloset

class MyClosetTest2: XCTestCase {
    let firebase = FirebaseStorageManager.shared
    func testIdToName() {
        firebase.getSpecificAuth(id: "z90YCGM5omWLttNDIfebUi2cYkr2") { result in
            switch result {
            case .success(let author):
                XCTAssertEqual(author.name, "Jason")
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func testFetchSpecificData() {
        firebase.fetchSpecificData(id: "aw6wO825HIepafwE26w4uYFmLas1") { article in
            XCTAssertEqual(article.author.name, "irena0804")
        }
    }
    
}
