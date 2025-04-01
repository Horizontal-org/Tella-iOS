//
//  ResponseStringExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

extension String {
    func parseHTTPResponse() -> HTTPResponse? { 
        let lines = self.components(separatedBy: "\r\n")
        guard let requestLine = lines.first, !requestLine.isEmpty else { return nil }
        
        // Extract the method and endpoint
        let requestComponents = requestLine.components(separatedBy: " ")
        guard requestComponents.count >= 3 else { return nil }
        let method = requestComponents[0]
        let rawEndpoint = requestComponents[1]
        
        // Separate endpoint and query parameters
        let endpointComponents = rawEndpoint.components(separatedBy: "?")
        let endpoint = endpointComponents[0]
        var queryParameters = [String: String]()
        
        if endpointComponents.count > 1 {
            let queryString = endpointComponents[1]
            let queryItems = queryString.components(separatedBy: "&")
            for item in queryItems {
                let pair = item.components(separatedBy: "=")
                if pair.count == 2 {
                    let key = pair[0].removingPercentEncoding ?? pair[0]
                    let value = pair[1].removingPercentEncoding ?? pair[1]
                    queryParameters[key] = value
                }
            }
        }
        
        // Extract headers
        var headers = Headers()
        var isHeaderSection = true
        var body = ""
        
        for line in lines.dropFirst() {
            if line.isEmpty {
                // Blank line indicates end of headers
                isHeaderSection = false
                continue
            }
            
            if isHeaderSection {
                let headerComponents = line.components(separatedBy: ": ")
                if headerComponents.count == 2 {
                    let key = headerComponents[0]
                    let value = headerComponents[1]
                    //                    headers[key] = value
                    switch key {
                    case "Content-Length" :
                        headers.contentLength = value
                    case "Content-Type" :
                        headers.contentType = value
                    default:
                        break
                    }
                }
            } else {
                // Collect body content
                body.append(line + "\n")
            }
        }
        
        return HTTPResponse(method: method,
                            endpoint: endpoint,
                            queryParameters: queryParameters,
                            headers: headers,
                            body: body.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

struct Headers {
    var contentLength : String?
    var contentType : String?
}

struct HTTPResponse {
    var method : String
    var endpoint : String
    var queryParameters : [String:String]
    var headers : Headers
    var body : String
}
