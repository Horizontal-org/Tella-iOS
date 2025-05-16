//
//  HTTPResponseBuilder.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

/// Class to generate HTTP responses for JSON content
class HTTPResponseBuilder {
    /// Generates an HTTP response with JSON content
    /// - Parameters:
    ///   - body: The body content as a dictionary
    ///   - statusCode: The HTTP status code (default is 200 OK)
    /// - Returns: A `Data` object representing the full HTTP response
    static func buildResponse(body: Codable,
                              statusCode: Int = 200) -> Data? {
        
        // Serialize the dictionary to JSON data
        guard let jsonData = body.dictionary.jsonData else {
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
    
    static func buildErrorResponse(error: String,
                                   statusCode: Int = 400) -> Data? {
        
        // Create error dictionary
        let errorBody: [String: String] = ["error": error]
        let jsonData = errorBody.jsonData ?? Data()
        
        // Response headers
        let statusLine = "HTTP/1.1 \(statusCode) Error\r\n"
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
