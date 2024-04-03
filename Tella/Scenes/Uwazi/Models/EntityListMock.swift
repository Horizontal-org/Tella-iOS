//
//  EntityListMock.swift
//  Tella
//
//  Created by gus valbuena on 3/26/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct EntityRelationshipItem: Identifiable, Codable {
    let id: String
    let label: String
}

struct MockDataProvider {
    static var values: [EntityRelationshipItem] = [
        EntityRelationshipItem(id: "j4xlwl9x3q", label: "Raph"),
        EntityRelationshipItem(id: "g29oj5qq5qf", label: "tt"),
        EntityRelationshipItem(id: "25dlpwut2kb", label: "Test"),
        EntityRelationshipItem(id: "fv2y7idlbw5", label: "Test wafa")
    ]
}
