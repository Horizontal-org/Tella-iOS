//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class Feedback: Codable {
    
    var id: Int?
    var text: String?
    var status : FeedbackStatus?
    var createdAt, updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case text = "c_text"
        case status = "c_status"
        case createdAt = "c_created_date"
        case updatedAt = "c_upated_date"
    }
    
    init(id: Int? = nil, text: String?, status: FeedbackStatus?, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.text = try container.decode(String.self, forKey: .text)
        
        let status = try container.decode(Int.self, forKey: .status)
        
        self.status = FeedbackStatus(rawValue: status)
        let createdDate = try container.decode(Double.self, forKey: .createdAt)
        self.createdAt = createdDate.getDate()
        
        let updatedAt = try container.decode(Double.self, forKey: .updatedAt)
        self.updatedAt = updatedAt.getDate()
    }
}
