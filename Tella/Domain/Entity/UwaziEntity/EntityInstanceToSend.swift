//
//  EntityInstanceToSend.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/4/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


class EntityInstanceToSend : Encodable {
    
    var attachments: [EntityAttachment]?
    var documents: [EntityAttachment]?
    var template : String?
    var title : String?
    var type : String = "entity"
    
    enum CodingKeys:  String,CodingKey {
        case metadata = "metadata"
        case template = "template"
        case title = "title"
        case type = "type"
        case attachments = "attachments"
        case documents = "documents"
    }
    
    init(attachments: [EntityAttachment]? ,
         documents: [EntityAttachment]? = nil,
         template: String? = nil,
         title: String? = nil,
         metadata: [String : Any]? = nil) {
        self.attachments = attachments
        self.documents = documents
        self.template = template
        self.title = title
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(documents, forKey: .documents)
        try container.encode(template, forKey: .template)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
    }
}
