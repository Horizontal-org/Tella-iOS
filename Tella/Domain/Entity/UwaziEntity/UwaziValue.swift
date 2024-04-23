//
//  UwaziValue.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziGeoData: ObservableObject {
    var label: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
}


class UwaziValue<T:Codable>: ObservableObject, Codable {
    
    @Published var value : T
    var label : String?
    var type : String?
    
    
    private enum CodingKeys: String, CodingKey {
        case value = "value"
        case label = "label"
        case type = "type"
        
    }
    init(value : T, label: String? = nil, type: String? = nil) {
        self.value = value
        self.label = label
        self.type = type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        if let label {
            try container.encode(label, forKey: .label)
        }
        if let type {
            try container.encode(type, forKey: .type)
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
        label = try container.decode(String.self, forKey: .label)
        type = try container.decode(String.self, forKey: .type)
    }
    
}
