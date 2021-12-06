//
//  HomeData.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct HomeFileItem : Hashable {
    var title : String
    var imageName : String
    var fileType: FileType?
}

var homeFileItems : [HomeFileItem] = [ HomeFileItem(title: LocalizableHome.allFilesItem.localized,
                                                    imageName: "files.all_files",
                                                    fileType: nil),
                                       HomeFileItem(title: LocalizableHome.imagesItem.localized,
                                                    imageName: "files.gallery",
                                                    fileType: .image),
                                       HomeFileItem(title: LocalizableHome.videosItem.localized,
                                                    imageName: "files.gallery",
                                                    fileType: .video),
                                       HomeFileItem(title: LocalizableHome.audioItem.localized,
                                                    imageName: "files.audio",
                                                    fileType: .audio),
                                       HomeFileItem(title: LocalizableHome.documentsItem.localized,
                                                    imageName: "files.documents",
                                                    fileType: .document),
                                       HomeFileItem(title: LocalizableHome.othersItem.localized,
                                                    imageName: "files.others",
                                                    fileType: .unknown),
]
