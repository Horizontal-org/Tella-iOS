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
    var filterType: FilterType
}

var homeFileItems : [HomeFileItem] { return [ HomeFileItem(title: LocalizableHome.tellaFilesAllFiles.localized,
                                                           imageName: "files.all_files",
                                                           filterType: .all),
                                              HomeFileItem(title: LocalizableHome.tellaFilesImages.localized,
                                                           imageName: "files.gallery",
                                                           filterType: .photo),
                                              HomeFileItem(title: LocalizableHome.tellaFilesVideos.localized,
                                                           imageName: "files.gallery",
                                                           filterType: .video),
                                              HomeFileItem(title: LocalizableHome.tellaFilesAudio.localized,
                                                           imageName: "files.audio",
                                                           filterType: .audio),
                                              HomeFileItem(title: LocalizableHome.tellaFilesDocuments.localized,
                                                           imageName: "files.documents",
                                                           filterType: .documents),
                                              HomeFileItem(title: LocalizableHome.tellaFilesOthers.localized,
                                                           imageName: "files.others",
                                                           filterType: .others),
]
    
}
