//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import XCTest
@testable import Tella


extension Data {
    
    init?(random length: Int) {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        if result == errSecSuccess {
            self = keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
}

extension XCTestCase {
    
    func loadImage(named: String) -> UIImage? {
        let bundle = Bundle.init(for: Self.self)
        return UIImage(named: "Image", in: bundle, compatibleWith: nil)
    }
    
}

class VaultManagerTests: XCTestCase {
 
    static let rootFileName = "rooFile"
    static let containerPath = ""
    let vault = VaultManager(cryptoManager: MockCryptoManager(), fileManager: DefaultFileManager(), rootFileName: VaultManagerTests.rootFileName, containerPath: containerPath)
    
    override func setUp() {
        vault.removeAllFiles()
    }

    override func tearDown() {
        vault.removeAllFiles()
    }

    func test_save_load_string() {
        let string = UUID().uuidString
        let file = vault.save(string, type: .document, name: "My Document", parent: nil, fileExtension: "")
        XCTAssertNotNil(file)
        XCTAssertEqual(vault.load(file: file!), string.data)
    }

    func test_save_load_data() {
        let data = Data(random: Int.random(in: 0..<1000))
        XCTAssertNotNil(data)
        let file = vault.save(data!, type: .document, name: "My Document", parent: nil)
        XCTAssertNotNil(file)
        XCTAssertEqual(vault.load(file: file!), data)
    }

    func test_save_load_image() {
        let bundle = Bundle.init(for: VaultManagerTests.self)
        let image = loadImage(named: "Image")
        
        XCTAssertNotNil(image)
        let file = vault.save(image!, type: .image, name: "My Image", parent: nil)
        XCTAssertNotNil(file)
        XCTAssertEqual(vault.load(file: file!), image?.data)
    }

    func test_save_load_video() {
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
