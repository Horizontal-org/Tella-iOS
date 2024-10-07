//
//  DropboxFileInfo.swift
//  Tella
//
//  Created by gus valbuena on 10/7/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct DropboxFileInfo {
    let url: URL
    let fileName: String
    let fileId: String
    let offset: Int64?
    let sessionId: String?
}
