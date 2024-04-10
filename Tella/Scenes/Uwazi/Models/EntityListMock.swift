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
    let values: [EntityRelationshipItem]?
}
