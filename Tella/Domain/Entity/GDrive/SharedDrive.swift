//
//  SharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class SharedDrive: DomainModel {
    var id: String
    var name: String
    var kind: String
    
    init(id: String, name: String, kind: String) {
        self.id = id
        self.name = name
        self.kind = kind
    }
}

var SharedDrivesList: [SharedDrive] = [
    SharedDrive(id: "1", name: "Admin", kind: "drive#drive"),
    SharedDrive(id: "2", name: "Backup", kind: "drive#drive"),
    SharedDrive(id: "3", name: "Community", kind: "drive#drive"),
    SharedDrive(id: "4", name: "Contact database", kind: "drive#drive"),
    SharedDrive(id: "5", name: "Incident reports", kind: "drive#drive")
]
