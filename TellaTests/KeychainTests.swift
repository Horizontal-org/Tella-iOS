//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import XCTest

import XCTest
@testable import Tella

class KeychainTests: XCTestCase {

    struct FileObject: Codable {
        var string = UUID().uuidString
        var data = UUID().uuidString.data(using: .utf8)!
    }
    
    let storage = KeychainManager()
    let secretKey = "tella.internews.com"
    let secretData = UUID().uuidString.data(using: .utf8)!
    let secretString = UUID().uuidString

    override func setUpWithError() throws {
        storage.remove(key: secretKey)
    }

    override func tearDownWithError() throws {
        storage.remove(key: secretKey)
    }

    func test_saveKeychainData(){
        storage.save(key: secretKey, data: secretData)
        let savedData: Data? = storage.load(key: secretKey)
        XCTAssertNotNil(savedData)
        XCTAssertEqual(savedData, secretData)
    }

    func test_saveKeychainString(){
        storage.save(key: secretKey, string: secretString)
        let savedString: String? = storage.load(key: secretKey)
        XCTAssertNotNil(savedString)
        XCTAssertEqual(savedString, secretString)
    }

    func test_saveKeychainObject(){
        let object = FileObject()
        storage.save(key: secretKey, object: object)
        let savedObject: FileObject? = storage.load(key: secretKey)
        XCTAssertNotNil(savedObject)
        XCTAssertEqual(savedObject?.string, object.string)
        XCTAssertEqual(savedObject?.data, object.data)
    }
    
    func test_removeKeychainData() {
        storage.save(key: secretKey, data: secretData)
        var savedData: Data? = storage.load(key: secretKey)
        XCTAssertNotNil(savedData)
        XCTAssertEqual(savedData, secretData)
        
        storage.remove(key: secretKey)
        savedData = storage.load(key: secretKey)
        XCTAssertNil(savedData)
    }

}
