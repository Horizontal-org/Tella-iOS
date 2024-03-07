//
//  UwaziCheckURL.swift
//  Tella
//
//  Created by Robert Shrestha on 9/5/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class UwaziCheckURL: DomainModel {
    var id: String?
    var siteName: String?
    var isPrivate: Bool?

    init(id: String?, siteName: String?, isPrivate: Bool?) {
        self.id = id
        self.siteName = siteName
        self.isPrivate = isPrivate
    }
}
