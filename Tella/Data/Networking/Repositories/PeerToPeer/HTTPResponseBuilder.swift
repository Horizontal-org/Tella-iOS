//
//  HTTPResponseBuilder.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

extension HTTPError {
    
    func buildErrorResponse() -> Data? {
        
        // Create error dictionary
        let errorBody: [String: String] = ["error": self.message]
        let jsonData = errorBody.jsonData ?? Data()
        
        // Response headers
        let statusLine = "HTTP/1.1 \(self.rawValue) Error\r\n"
        let headers = """
        Content-Type: application/json\r
        Content-Length: \(jsonData.count)\r\n\r\n
        """
        
        // Combine headers and body
        guard let headerData = (statusLine + headers).data(using: .utf8) else {
            return nil
        }
        
        return headerData + jsonData
    }
}

extension Encodable {
    
    func buildResponse() -> Data? {
        let statusCode: Int = 200
        // Serialize the dictionary to JSON data
        guard let jsonData = self.dictionary.jsonData else {
            return nil
        }
        
        // Response headers
        let statusLine = "HTTP/1.1 \(statusCode) OK\r\n"
        let headers = """
        Content-Type: application/json\r
        Content-Length: \(jsonData.count)\r\n\r\n
        """
        
        // Combine headers and body
        guard let headerData = (statusLine + headers).data(using: .utf8) else {
            return nil
        }
        return headerData + jsonData
    }
}
