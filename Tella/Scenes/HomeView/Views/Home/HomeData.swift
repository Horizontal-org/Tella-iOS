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

var homeFileItems : [HomeFileItem] { return [ HomeFileItem(title: Localizable.Home.tellaFilesAllFiles,
                                                    imageName: "files.all_files",
                                                    fileType: nil),
                                              HomeFileItem(title: Localizable.Home.tellaFilesImages,
                                                    imageName: "files.gallery",
                                                    fileType: [.image]),
                                              HomeFileItem(title: Localizable.Home.tellaFilesVideos,
                                                    imageName: "files.gallery",
                                                    fileType: [.video]),
                                              HomeFileItem(title: Localizable.Home.tellaFilesAudio,
                                                    imageName: "files.audio",
                                                    fileType: [.audio]),
                                              HomeFileItem(title: Localizable.Home.tellaFilesDocuments,
                                                    imageName: "files.documents",
                                                    fileType: [.document]),
                                              HomeFileItem(title: Localizable.Home.tellaFilesOthers,
                                                    imageName: "files.others",
                                                    fileType: [.other]),
]
    
}
