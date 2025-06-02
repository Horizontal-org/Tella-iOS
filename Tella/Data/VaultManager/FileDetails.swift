//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct FileDetails {
    var file : VaultFileDB
    var data : Data
    var fileUrl : URL
}

struct VaultFileDetails {
    var file : VaultFileDB
    var importedFile :ImportedFile
}
