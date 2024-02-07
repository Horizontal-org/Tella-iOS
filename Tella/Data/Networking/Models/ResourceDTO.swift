//
//  ResourceDTO.swift
//  Tella
//
//  Created by gus valbuena on 2/7/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct ResourceDTO: Codable {
    let id: String
    let name: String
    let slug: String
    let url: String
    let resources: [Resource]
    let createdAt: String
}
