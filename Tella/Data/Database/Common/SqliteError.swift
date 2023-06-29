//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3

// Indicates an exception during a SQLite Operation.
class SqliteError : Error {
    var message : String?
    var error = SQLITE_ERROR
    
    init(message: String? = nil) {
        self.message = message
        guard let message else { return }
        debugLog(message, level: .debug)
    }
    
    init(error: Int32) {
        self.error = error
    }
}
