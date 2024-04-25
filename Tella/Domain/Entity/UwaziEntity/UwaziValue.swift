//
//  UwaziValue.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziValue<T:Codable>: ObservableObject, Codable {
    
    @Published var value : T
    
    
    private enum CodingKeys: String, CodingKey {
        case value = "value"
        
    }
    init(value : T, label: String? = nil, type: String? = nil) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
    }
    
}
