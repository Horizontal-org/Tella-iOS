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

    init(id: String?, siteName: String?) {
        self.id = id
        self.siteName = siteName
    }
}
