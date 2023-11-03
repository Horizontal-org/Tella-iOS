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
        
        // Add attachments
        attachments?.enumerated().forEach { index, attachment in
            multipartRequest.add(
                key: "attachments[\(index)]",
                fileName: attachment.filename,
                fileMimeType: attachment.mimeType,
                fileData: attachment.data
            )
            multipartRequest.add(key: "attachments_originalname[\(index)]", value: attachment.filename)
        }
                
                // Add documents
        documents?.enumerated().forEach { index, document in
            multipartRequest.add(
                key: "documents[\(index)]",
                fileName: document.filename,
                fileMimeType: document.mimeType,
                fileData: document.data
            )
            multipartRequest.add(key: "documents_originalname[\(index)]", value: document.filename)
        }
        
        return (
            body: multipartRequest.httpBody,
            ContentTypeHeader: multipartRequest.httpContentTypeHeadeValue
        )
    }
}
