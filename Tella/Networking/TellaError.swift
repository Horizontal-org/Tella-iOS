//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

public class TellaError: Error {
    
    // MARK: Properties
    public var message: String = ""
    public var code: Int?
    
    init(httpResponse: HTTPURLResponse) {
        
        switch httpResponse.statusCode {
        case 401:
            self.message = "The username or password is incorrect"
        default:
            self.message = "Error"
        }
        self.code = httpResponse.statusCode
    }
    
    init(error:Error) {
        self.message = "The URL is incorrect"
        self.code = (error as NSError).code
    }
    
    init(tellaError:TellaError) {
        self.message = "url is incorrect"
        self.code = tellaError.code
    }

    
    init() {
        self.message = "General error"
        self.code = -1
    }

    
}
