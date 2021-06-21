//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

enum FileType: String, Codable {
    case video
    case audio
    case document
    case image
    case folder
}

class VaultFile: Codable, RecentFileProtocol, Hashable {
    
    func hash(into hasher: inout Hasher){
        hasher.combine(containerName.hashValue)
    }
    
    let type: FileType
    var fileName: String
    let containerName: String
    var files: [VaultFile]
    var thumbnail: Data?
    var created: Date
    
    static func rootFile(containerName: String) -> VaultFile {
        return VaultFile(type: .folder, fileName: "", containerName: containerName, files: [])
    }

    init(type: FileType, fileName: String, containerName: String, files: [VaultFile]?) {
        self.type = type
        self.fileName = fileName
        self.containerName = containerName
        self.files = files ?? []
        self.created = Date()
    }
    
    var thumbnailImage: UIImage {
        if let thumbnail = thumbnail, let image = UIImage(data: thumbnail) {
            return image
        }
        return UIImage()
    }
    
    var iconImage: UIImage {
        switch type {
        case .audio:
           return #imageLiteral(resourceName: "filetype.audio")
        case .document:
            return #imageLiteral(resourceName: "filetype.document")
        case .folder:
            return #imageLiteral(resourceName: "filetype.folder")
        case .video:
            return #imageLiteral(resourceName: "filetype.video")
        case .image:
            return #imageLiteral(resourceName: "filetype.document")
        }
    }

    
    func add(file: VaultFile) {
        fileName = UUID().uuidString
        files.append(file)
    }

    func remove(file: VaultFile) {
    }

    static func sorted(files: [VaultFile], by sortOrder: FileSortOptions, filter: FileType? = nil) -> [VaultFile] {
        return files.sorted { file1, file2 in

            if file1.type == .folder && file2.type == .folder {
                return file1.fileName > file2.fileName
            }
            
            if file1.type == .folder {
                return true
            }
            if file2.type == .folder {
                return false
            }

            switch sortOrder {
            case .nameAZ:
                return file1.fileName > file2.fileName
            case .nameZA:
                return file1.fileName < file2.fileName
            case .newestToOldest:
                return file1.created < file2.created
            case .oldestToNewest:
                return file1.created > file2.created
            }
        }
    }

    
}

extension VaultFile: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(type): \(String(describing: fileName)), \(containerName), \(files.count)"
    }
    
}

extension VaultFile: Equatable {
    
    static func == (lhs: VaultFile, rhs: VaultFile) -> Bool {
        lhs.fileName == rhs.fileName &&
        lhs.containerName == rhs.containerName
    }
    
}
