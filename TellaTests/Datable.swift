//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import XCTest
@testable import Tella

class Datable: XCTestCase {

    func test_string() throws {
        let string = UUID().uuidString
        XCTAssertEqual(string.data, string.data(using: .utf8))
    }

    func test_image() throws {
        let string = UUID().uuidString
        XCTAssertEqual(string.data, string.data(using: .utf8))
    }

}
