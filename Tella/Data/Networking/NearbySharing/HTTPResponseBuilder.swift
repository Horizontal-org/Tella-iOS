//
//  HTTPResponse.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class HTTPResponseBuilder {
    private var response: HTTPResponse
    
    init(serverStatus: ServerStatus) {
        self.response = HTTPResponse(serverStatus: serverStatus)
    }
    
    func setContentType(_ contentType: ContentType) -> Self {
        response.addHeader(name: HTTPHeaderField.contentType.rawValue, value: contentType.rawValue)
        return self
    }
    
    func setBody<T: Encodable>(_ body: T?) -> Self {
        guard let data = body?.jsonData else {
            response.addHeader(name: HTTPHeaderField.contentLength.rawValue, value: "0")
            return self
        }
        response.body = data
        response.addHeader(name: HTTPHeaderField.contentLength.rawValue, value: "\(data.count)")
        return self
    }
    
    func closeConnection() -> Self {
        response.addHeader(name: HTTPHeaderField.connection.rawValue, value: "close")
        return self
    }
    
    func build() -> Data? {
        return response.serialized()
    }
}

fileprivate struct HTTPField {
    let name: String
    let value: String
}

struct ErrorResponse: Codable {
    let error: String
}

fileprivate struct HTTPResponse {
    
    var serverStatus: ServerStatus
    var headerFields: [HTTPField] = []
    var body: Data?
    
    mutating func addHeader(name: String, value: String) {
        headerFields.append(HTTPField(name: name, value: value))
    }
    
    func serialized() -> Data? {
        var responseString = "HTTP/1.1 \(serverStatus.code.rawValue) \(serverStatus.message.rawValue)\r\n"
        for field in headerFields {
            responseString += "\(field.name): \(field.value)\r\n"
        }
        responseString += "\r\n"
        
        var responseData = responseString.data
        if let body = body {
            responseData?.append(body)
        }
        return responseData
    }
}

