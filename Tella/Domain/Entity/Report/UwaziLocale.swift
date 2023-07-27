//
//  UwaziLocale.swift
//  Tella
//
//  Created by Robert Shrestha on 7/21/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

class UwaziLocale : Hashable, Codable {

    var id : Int?
    var locale : String?
    var serverId : Int?

    init(id: Int? = nil,
         locale: String? = nil,
         serverId: Int? = nil ,
         title: Int? = nil
        ) {
        self.id = id
        self.locale = locale
        self.serverId = serverId
    }
    enum CodingKeys: String, CodingKey {
        case id = "c_locale_id"
        case locale = "c_locale"
        case serverId = "c_server_id"
    }

    static func == (lhs: UwaziLocale, rhs: UwaziLocale) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
