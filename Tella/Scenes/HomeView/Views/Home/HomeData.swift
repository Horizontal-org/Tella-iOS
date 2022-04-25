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
    var fileType: [FileType]?
}

var homeFileItems : [HomeFileItem] { return [ HomeFileItem(title: Localizable.Home.allFilesItem,
                                                    imageName: "files.all_files",
                                                    fileType: nil),
                                              HomeFileItem(title: Localizable.Home.imagesItem,
                                                    imageName: "files.gallery",
                                                    fileType: [.image]),
                                              HomeFileItem(title: Localizable.Home.videosItem,
                                                    imageName: "files.gallery",
                                                    fileType: [.video]),
                                              HomeFileItem(title: Localizable.Home.audioItem,
                                                    imageName: "files.audio",
                                                    fileType: [.audio]),
                                              HomeFileItem(title: Localizable.Home.documentsItem,
                                                    imageName: "files.documents",
                                                    fileType: [.document]),
                                              HomeFileItem(title: Localizable.Home.othersItem,
                                                    imageName: "files.others",
                                                    fileType: [.other]),
]
    
}
