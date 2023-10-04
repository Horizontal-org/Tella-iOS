//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI
import Combine


protocol VaultFilesManagerInterface {

    func addVaultFile(filePaths: [URL], parentId: String?) -> AnyPublisher<ImportVaultFileResult,Never>
    func addFolderFile(name:String, parentId: String?)
    func getVaultFiles(parentId: String?, filter: FilterType, sort: FileSortOptions?) -> [VaultFileDB]
    func getVaultFile(id: String?) -> VaultFileDB?
    func getVaultFiles(ids: [String]) -> [VaultFileDB]
    func getRecentVaultFiles() -> [VaultFileDB]
    func renameVaultFile(id: String?, name: String?)
    func moveVaultFile(fileIds: [String], newParentId: String?)
    func deleteVaultFile(fileIds: [String])
    func deleteVaultFile(vaultFiles: [VaultFileDB])

    func loadFileData(fileName: String?) -> Data?
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL]
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL?

    func loadFilesInfos(file vaultFile: VaultFileDB, offsetSize:Int ) -> VaultFileInfo?
    func saveDataToTempFile(data: Data, pathExtension:String) -> URL?
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL?
    func createTempFileURL(pathExtension: String) -> URL

    func clearTmpDirectory()
    func deleteContainerDirectory()
    func resetData()
    func deleteAllVaultFiles()
    
    
}

class VaultManager: ObservableObject {
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let cryptoManager: CryptoManager = CryptoManager.shared
    private let fileManager: FileManagerInterface = DefaultFileManager()
    private let rootFileName: String = "root"
    var cancellable: Set<AnyCancellable> = []
    
    internal let containerPath: String = "Containers"
    
//    @Published var root: VaultFile?
    
    @Published var tellaData : TellaData?
    @Published var vaultDataSource : VaultDataSourceInterface?
    
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    
    func resetData() {
        self.tellaData = nil
        self.vaultDataSource = nil
    }
    
    
    func initFiles() -> AnyPublisher<Bool,Never> {
        return Deferred {
            Future <Bool,Never> {  [weak self] promise in
                guard let self = self else { return }
                Task {
                    self.mergeRootFilesToDatabase()
                    promise(.success(true))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func mergeRootFilesToDatabase() {
        if let root = self.load(name: self.rootFileName) {
            var vaultFileResult : [VaultFileDB] = []
            getFiles(root: root, vaultFileResult: &vaultFileResult)
        }
    }

    func getFiles(root: VaultFile, vaultFileResult: inout [VaultFileDB], parentId: String? = nil) {
        root.files.forEach { file in
            
            let vaultFile = VaultFileDB(vaultFile:file)
            self.vaultDataSource?.addVaultFile(file: vaultFile, parentId: parentId)

            if file.type == .folder {
                getFiles(root: file, vaultFileResult: &vaultFileResult, parentId: file.id)
            }
        }
    }

    private func initialize(with key:String?) {
        
        self.tellaData = TellaData(key: key)
        self.vaultDataSource = VaultDataSource(key: key)

        do { //TODO: Dhekra
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugLog(error)
        }
    }

    // To decrypt root
    private func load(name: String) -> VaultFile? { // ✅
        debugLog("\(name)", space: .files)
        
        let fileURL = containerURL(for: name)
        debugLog("loading \(fileURL)")
        do {
            let encryptedData = try Data(contentsOf: fileURL)
            if let decrypted = cryptoManager.decrypt(encryptedData) {
                return try decoder.decode(VaultFile.self, from: decrypted)
            } else {
                debugLog("file load failed \(name)")
            }
        } catch let error {
            debugLog(error)
        }
        return nil
    }

      func save(_ data: Data, vaultFile: VaultFileDB) -> Bool? { // ✅
        debugLog("\(data.count); \(vaultFile.type); \(vaultFile.name)", space: .files)
          guard let id = vaultFile.id else { return false }
        let fileURL = containerURL(for: id)
        guard let encrypted = cryptoManager.encrypt(data),
              fileManager.createFile(atPath: fileURL, contents: encrypted) else {
            debugLog("encryption failed \(String(describing: vaultFile.name))", level: .debug, space: .crypto)
            return nil
        }
        return true
    } // ✅
    
    
    private func save<T: Datable>(_ object: T, vaultFile: VaultFileDB) -> Bool? { // ✅
        guard let data = object.data else {
            return nil
        }
        return save(data, vaultFile: vaultFile)
    } // ✅
    
    private func containerURL(for containerName: String) -> URL { // ✅
        return containerURL.appendingPathComponent(containerName)
    } // ✅
    
    private var containerURL: URL { // ✅
        
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(containerPath)
        return url
    } // ✅

    
    
    func loadFileData(fileName: String?) -> Data? { // ✅
        guard let fileId = fileName else { return nil}
        
        debugLog("\(fileId)", space: .files)
        
        let fileURL = containerURL(for: fileId)
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    } // ✅
    
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL? { // ✅
        
        let data = self.loadFileData(fileName: vaultFile.id)
        
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.name).appendingPathExtension(vaultFile.fileExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    } // ✅
    
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL] { // ✅
        
        var tmpUrlArray : [URL] = []
        
        vaultFiles.forEach { vaultFile in
            if vaultFile.type != .directory {
                guard let url = self.loadVaultFileToURL(file: vaultFile) else { return } //TODO: Dhekra to be tested
                tmpUrlArray.append(url)
            }
        }
        return tmpUrlArray
    } // ✅
    
    func loadFilesInfos(file vaultFile: VaultFileDB, offsetSize:Int ) -> VaultFileInfo? { // ✅
        
        if vaultFile.type != .directory {
            guard var data = self.loadFileData(fileName: vaultFile.id) else {return nil }
            
            guard let extractedData = (data.extract(size: offsetSize)) else {return nil }
            
            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(vaultFile.name).appendingPathExtension(vaultFile.fileExtension)
            
            if fileManager.createFile(atPath: tmpFileURL, contents: extractedData) {
                return VaultFileInfo(vaultFile: vaultFile,data: extractedData,url: tmpFileURL)
            }
        }
        return nil
    } // ✅

    func saveDataToTempFile(data: Data, pathExtension: String) -> URL? {
        let tmpFileURL = self.createTempFileURL(pathExtension: pathExtension)
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func createTempFileURL(pathExtension: String) -> URL {
        return URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(Int(Date().timeIntervalSince1970))").appendingPathExtension(pathExtension)
    }
    
    func saveDataToTempFile(data: Data?, fileName: String, pathExtension:String) -> URL? {
        let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(fileName).appendingPathExtension(pathExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func deleteAllVaultFilesFromDevice() { // ✅
        debugLog("", space: .files)
        fileManager.removeItem(at: containerURL)
    } // ✅
    
    func deleteVaultFile(filesIds: [String]) { // ✅
        filesIds.forEach { fileId in
            debugLog("\(fileId)", space: .files)
//            if file.type != .directory {
                let fileURL = containerURL(for: fileId)
                fileManager.removeItem(at: fileURL)
//            }
        }
    } // ✅
    
    func clearTmpDirectory() { // ✅
        let tmpDirectory =  fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
        tmpDirectory.forEach {[unowned self] file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            fileManager.removeItem(at: path)
        }
    }// ✅

    func deleteContainerDirectory() { // ✅
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let fileName = fileManager.contentsOfDirectory(atPath: paths)
        
        fileManager.removeContainerDirectory(fileName: fileName, paths: paths)
    } // ✅
    
}

//  VaultManager extension contains the methods used for authentication

extension VaultManager {
    
    func keysInitialized() -> Bool {
        return self.cryptoManager.keysInitialized()
    }
    
    func login(password:String?) -> Bool {
        do {
            guard let key = try self.recoverKey(password: password)?.getString() else { return false}
            self.initialize(with: key)
            return true
        }
        catch let error {
            debugLog(error)
            return false
        }
    }
    
    private func recoverKey( password:String? = nil) throws -> SecKey?  {
        return cryptoManager.recoverKey(.PRIVATE, password: password)
    }
    
    func initKeys(_ type: PasswordTypeEnum, password:String) {
        do {
            try cryptoManager.initKeys(type, password: password)
            let key = try self.recoverKey(password: password)?.getString()
            self.initialize(with: key)
        }
        catch let error {
            debugLog(error)
        }
    }
    
    func updateKeys(_ type: PasswordTypeEnum, newPassword:String, oldPassword:String)  {
        do {
            guard let privateKey = try self.recoverKey(password: oldPassword) else { return }
            try cryptoManager.updateKeys(privateKey, type, newPassword:newPassword, oldPassword: oldPassword)
        }
        catch let error {
            debugLog(error)
        }
    }
    
    func getPasswordType() -> PasswordTypeEnum {
        return cryptoManager.passwordType
    }

}

//  VaultManager extension contains the methods used to restore files

extension VaultManager {
    
    private func load(fileURL: URL) -> Data? {
        debugLog("\(fileURL)", space: .files)
        
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }
    
    private func recoverFiles() async {
        let filesToRestore = self.getFilesToRestore()
        await self.recoverFiles(filesToRestore: filesToRestore)
    }
    
    private func getFilesToRestore() -> [String] {
        var vaultFileResult : [VaultFile] = []
        self.root?.getAllFiles(vaultFileResult: &vaultFileResult)
        let rootContainerName = vaultFileResult.compactMap{$0.containerName }
        
        // return all the content of directory
        let containerURLContent =  fileManager.contentsOfDirectory(atPath: containerURL)
        let allContainerName = containerURLContent.compactMap{$0.lastPathComponent }
        
        let rootContainerNameSet:Set<String> = Set(rootContainerName)
        var allContainerNameSet:Set<String> = Set(allContainerName)
        
        allContainerNameSet.subtract(rootContainerNameSet)
        
        return Array(allContainerNameSet)
        
        
    }
    
    private func saveRetoredFilesToTempFiles(fileToRestore:String) -> URL? {
        
        let fileURL = containerURL(for: fileToRestore)
        
        if fileToRestore != self.rootFileName {
            
            guard let fileData = load(fileURL: fileURL) , var fileExtension = fileData.fileExtension(vaultManager: self) else { return nil}
            
            if fileExtension == FileType.zip.rawValue {
                guard let fileTmpPath = saveDataToTempFile(data: fileData, pathExtension: fileExtension) else { return nil}
                guard let officeExtension =  fileTmpPath.getOfficeExtension() else { return nil }
                fileExtension = officeExtension
            }
            let fileName = fileExtension.getRecoveredFileName()
            return saveDataToTempFile(data: fileData, fileName: fileName, pathExtension: fileExtension)
        }
        
        return nil
    }
    
    private func recoverFiles(filesToRestore: [String]) async {
        
        do {
            for fileToRestore in filesToRestore {
                
                guard let fileDetail = try await self.getFilesInfos(fileToRestore: fileToRestore) else {continue}
                
                autoreleasepool {
                    self.save(fileDetail.data, vaultFile: fileDetail.file)
                    self.fileManager.removeItem(at: fileDetail.fileUrl)
                }
            }
        }
        catch {
            debugLog("Failed to get files infos")
        }
    }
    
    private func getFilesInfos(fileToRestore: String) async throws -> FileDetails?  {
        
        guard  let filePath =  self.saveRetoredFilesToTempFiles(fileToRestore: fileToRestore) else { return nil}
        
        
        
        ///----------------------------------------
        let _ = filePath.startAccessingSecurityScopedResource()
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: filePath)
        
        async let thumnail = await filePath.thumbnail()
        let fileName = filePath.deletingPathExtension().lastPathComponent
        let path = filePath.path
        let pathExtension = filePath.pathExtension
        let resolution = filePath.resolution()
        let duration =  filePath.getDuration()
        let size = FileManager.default.sizeOfFile(atPath: path) ?? 0
        let pathArray = [""]
       
        // TODO: - Dhekra To ask Caro -
        
//        let vaultFile = await VaultFileDB(type: filePath.fileType,
//                                        fileName: fileName,
//                                        containerName: fileToRestore,
//                                        files: nil,
//                                        thumbnail: thumnail,
//                                        fileExtension: pathExtension,
//                                        size:size,
//                                        resolution: resolution,
//                                        duration: duration,
//                                        pathArray: pathArray)
//        ///-----------------------------------------
//
//
//        return (FileDetails(file: vaultFile, data: data, fileUrl: filePath))
        
        return nil
    }
}
