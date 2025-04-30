//
//  SharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class SharedDrive: DomainModel, Equatable {
    var id: String
    var name: String
    var kind: String
    
    init(id: String, name: String, kind: String) {
        self.id = id
        self.name = name
        self.kind = kind
    }
    
    static func == (lhs: SharedDrive, rhs: SharedDrive) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.kind == rhs.kind
    }
}
