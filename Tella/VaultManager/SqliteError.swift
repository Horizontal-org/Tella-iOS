//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3

// Indicates an exception during a SQLite Operation.
class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    
    init(message: String = "") {
        debugLog(message, level: .debug)
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
