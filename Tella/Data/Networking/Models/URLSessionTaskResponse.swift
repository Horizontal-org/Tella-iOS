//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class URLSessionTaskResponse {
    
    var current : Int?
    var task: URLSessionTask?
    var data :Data?
    var response :HTTPURLResponse?
    var error :Error?
    
    init(current: Int? = nil, task: URLSessionTask? = nil, data: Data? = nil, response: HTTPURLResponse? = nil, error :Error? = nil) {
        self.current = current
        self.task = task
        self.data = data
        self.response = response
        self.error = error
        
    }
}
