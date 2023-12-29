//
//  JSONDecoderExtension.swift
//  Tella
//
//  Created by Robert Shrestha on 9/14/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

extension JSONDecoder {
    func decode<T: Codable>(_ type: T.Type, from dictionary: Any) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try decode(type, from: data)
    }
}
