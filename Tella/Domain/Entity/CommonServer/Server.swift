//
//  Server.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 28/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

protocol ServerProtocol: Codable, Equatable, Hashable {
    var id: Int? { get set }
    var name: String? { get set }
    var serverType: ServerConnectionType? { get set }
    var allowMultiple: Bool? { get set }
}

extension ServerProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

class Server: Codable, Equatable, Hashable {
    
    var id: Int?
    var name: String?
    var serverType: ServerConnectionType?
    var allowMultiple: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case name = "c_name"
    }
    
    init(id: Int? = nil,
         name: String? = nil,
         serverType: ServerConnectionType? = nil,
         allowMultipleConnections: Bool? = true
    ) {
        self.id = id
        self.name = name
        self.serverType = serverType
        self.allowMultiple = allowMultipleConnections
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id.hashValue)
    }
}

