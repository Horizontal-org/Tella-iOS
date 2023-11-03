//
//  UwaziMultipartData.swift
//  Tella
//
//  Created by Gustavo on 03/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct UwaziMultipartFormDataBuilder {
    
    static func createBodyWith(
        keyValues: [String: Any],
        attachments: [UwaziAttachment]?,
        documents: [UwaziAttachment]?
    ) -> (body: Data, ContentTypeHeader: String) {
        
        let keyValues = keyValues.compactMapValues { $0 }
        var multipartRequest = MultipartRequest()
        
        for (key, value) in keyValues {
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    multipartRequest.add(key: key, value: jsonString)
                }
            }
        }
        
        return (
            body: multipartRequest.httpBody,
            ContentTypeHeader: multipartRequest.httpContentTypeHeadeValue
        )
    }
}
