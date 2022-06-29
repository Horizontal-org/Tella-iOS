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

var homeFileItems : [HomeFileItem] { return [ HomeFileItem(title: LocalizableHome.tellaFilesAllFiles.localized,
                                                    imageName: "files.all_files",
                                                    fileType: nil),
                                              HomeFileItem(title: LocalizableHome.tellaFilesImages.localized,
                                                    imageName: "files.gallery",
                                                    fileType: [.image]),
                                              HomeFileItem(title: LocalizableHome.tellaFilesVideos.localized,
                                                    imageName: "files.gallery",
                                                    fileType: [.video]),
                                              HomeFileItem(title: LocalizableHome.tellaFilesAudio.localized,
                                                    imageName: "files.audio",
                                                    fileType: [.audio]),
                                              HomeFileItem(title: LocalizableHome.tellaFilesDocuments.localized,
                                                    imageName: "files.documents",
                                                    fileType: [.document]),
                                              HomeFileItem(title: LocalizableHome.tellaFilesOthers.localized,
                                                    imageName: "files.others",
                                                    fileType: [.other]),
]
    
}
