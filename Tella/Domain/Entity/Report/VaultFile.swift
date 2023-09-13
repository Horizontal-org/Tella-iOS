//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation

enum TellaFileType: String, Codable {
    case video
    case audio
    case document
    case image
    case other
    case folder
}

class VaultFile: Codable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(containerName.hashValue)
    }
    var id: String?
    var type: TellaFileType
    var fileName: String
    var containerName: String
    var files: [VaultFile]
    var thumbnail: Data?
    var created: Date
    var fileExtension : String
    var size : Int
    var resolution : CGSize?
    var duration : Double?
    var pathArray : [String]
    var isSelected: Bool = false
    
    static func rootFile(fileName: String, containerName: String) -> VaultFile {
        return VaultFile(type: .folder, fileName: fileName, containerName: containerName, files: [], pathArray: [])
    }
    
    init(id:String? = UUID().uuidString, type: TellaFileType, fileName: String, containerName: String = UUID().uuidString, files: [VaultFile]? = nil, thumbnail: Data? = nil, created: Date = Date() , fileExtension : String = "", size : Int = 0, resolution : CGSize? = nil, duration : Double? = nil, pathArray :[String]) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.containerName = containerName
        self.files = files ?? []
        self.created = created
        self.thumbnail = thumbnail
        self.fileExtension = fileExtension
        self.size = size
        self.duration = duration
        self.resolution = resolution
        self.pathArray = pathArray
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
            return #imageLiteral(resourceName: "filetype.small_audio")
        case .document:
            return #imageLiteral(resourceName: "filetype.small_document")
        case .folder:
            return #imageLiteral(resourceName: "filetype.small_folder")
        case .video:
            return #imageLiteral(resourceName: "filetype.small_video")
        case .image:
            return UIImage()
        case .other:
            return #imageLiteral(resourceName: "filetype.small_document")
        }
    }
    
    var bigIconImage: UIImage {
        switch type {
        case .audio:
            return #imageLiteral(resourceName: "filetype.big_audio")
        case .document:
            return #imageLiteral(resourceName: "filetype.big_document")
        case .video:
            return #imageLiteral(resourceName: "filetype.big_video")
        case .image:
            return UIImage()
        case .folder:
            return #imageLiteral(resourceName: "filetype.big_folder")
        case .other:
            return #imageLiteral(resourceName: "filetype.big_document")
        }
    }
    
    
    func add(file: VaultFile) {
        files.append(file)
    }
    
    func remove(file: VaultFile) {
        if files.count > 0 {
            files = files.filter({ $0.containerName != file.containerName })
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

extension Array where Element == VaultFile {
    
    func filtered(with filter: TellaFileType?, includeFolders: Bool) -> [Element] {
        guard let filter = filter else {
            return self
        }
        return self.filter({ filter == ($0.type) || (includeFolders && $0.type == .folder)})
    }
    
    func sorted(by sortOrder: FileSortOptions, folderPathArray:[VaultFile] = [], root:VaultFile?, fileType:[TellaFileType]? = nil) -> [VaultFile] {
        
        guard let root else { return [] }
        
        var filteredFiles : [VaultFile] = []
        
        if let fileType = fileType {
            
            var vaultFileResult : [VaultFile] = []
            getFiles(root: root, vaultFileResult: &vaultFileResult, fileType: fileType)
            filteredFiles = vaultFileResult
            
        } else {
            var currentRootFile = root
            if !folderPathArray.isEmpty {
                for file in folderPathArray {
                    guard let rootFile = (currentRootFile.files.first {$0 == file}) else { return [] }
                    currentRootFile =  rootFile
                }
            }
            filteredFiles = currentRootFile.files
        }
        
        return filteredFiles.sorted(by: sortOrder)
    }
    
    
    func sorted(by sortOrder: FileSortOptions) -> [VaultFile] {
        return self.sorted { file1, file2  in
            
            switch sortOrder {
            case .nameAZ:
                return file1.fileName < file2.fileName
            case .nameZA:
                return file1.fileName > file2.fileName
            case .newestToOldest:
                return file1.created > file2.created
            case .oldestToNewest:
                return file1.created < file2.created
            }
        }
    }
    
    func getFiles(root: VaultFile, vaultFileResult: inout [VaultFile], fileType:[TellaFileType]) {
        root.files.forEach { file in
            switch file.type {
            case .folder:
                getFiles(root: file, vaultFileResult: &vaultFileResult, fileType: fileType)
            default:
                if fileType.contains(file.type) {
                    vaultFileResult.append(file )
                }
            }
        }
    }
}

extension VaultFile {
    func getVideos() ->  [VaultFile] {
        return self.files.filter{$0.type == .video}
    }
    
}

extension VaultFile {
    
    var formattedCreationDate : String {
        get {
            return created.fileCreationDate()
        }
    }
}

extension VaultFile {
    
    var longFormattedCreationDate : String {
        get {
            return created.getFormattedDateString(format: DateFormat.fileInfo.rawValue)
        }
    }
}

extension VaultFile {
    
    var formattedResolution : String? {
        get {
            guard let resolution = resolution else {return nil}
            return "\(Int(resolution.width)):\(Int(resolution.height))"
        }
    }
}

extension VaultFile {
    
    var formattedDuration : String? {
        get {
            guard let duration = duration else {return nil}
            return  duration.shortTimeString()
        }
    }
}

extension VaultFile {
    
    func getRecentFile() -> [RecentFile] {
        
        var vaultFileResult : [RecentFile] = []
        var rootFile = self
        var folderPathArray : [VaultFile] = []
        
        getRecentFile(root: self, vaultFileResult: &vaultFileResult,rootFile: &rootFile, folderPathArray: &folderPathArray)
        return vaultFileResult.limit(10)
    }
    
    func getRecentFile(root: VaultFile, vaultFileResult: inout [RecentFile], rootFile: inout VaultFile, folderPathArray:inout [VaultFile]) {
        
        root.files.forEach { file in
            switch file.type {
            case .folder:
                getRecentFile(root: file, vaultFileResult: &vaultFileResult, rootFile: &rootFile, folderPathArray:&folderPathArray)
            default:
                let recentFile = RecentFile(file: file, rootFile: rootFile, folderPathArray:  folderPathArray)
                vaultFileResult.append(recentFile)
            }
        }
    }
}


extension VaultFile {
    
    func getFile(root: VaultFile?, vaultFileResult: inout Set<VaultFile>, ids: [String])  {
        
        root?.files.forEach { file in
            switch file.type {
            case .folder:
                getFile(root: file, vaultFileResult: &vaultFileResult, ids: ids)
            default:
                if let id = file.id , ids.contains(id) {
                    vaultFileResult.insert(file)
                }
            }
        }
    }
    
    
    func updateIds()  {
        files.forEach { file in
            if file.id == nil {
                file.id = UUID().uuidString
                switch file.type {
                case .folder:
                    updateIds()
                default:
                    break
                }
            }
        }
    }
    
    func getAllFiles(vaultFileResult: inout [VaultFile])   {
        self.files.forEach { file in
            switch file.type {
            case .folder:
                file.getAllFiles(vaultFileResult: &vaultFileResult)
            default:
                vaultFileResult.append(file)
            }
        }
    }
    
    
}

