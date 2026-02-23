//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SwiftUI
import Combine

class VaultManager : VaultManagerInterface, ObservableObject{
    
    
    private let cryptoManager: CryptoManager = CryptoManager.shared
    private let fileManager: FileManagerInterface = DefaultFileManager()
    private let rootFileName: String = "root"
    private let containerPath: String = "Containers"
    
    var cancellable: Set<AnyCancellable> = []
    
    @Published var tellaData : TellaData?
    
    var shouldCancelImportAndEncryption = CurrentValueSubject<Bool,Never>(false)
    
    var onSuccessLock = PassthroughSubject<String,Never>()
    
    var key: String? {
        return cryptoManager.metaPrivateKey?.getString()
    }
    
    func save(_ filePath: URL, vaultFileId: String?) -> Bool? {
        guard let vaultFileId else { return false }
        debugLog("\(filePath)", space: .files)
        
        let outputFileURL = containerURL(for: vaultFileId)
        
        guard fileManager.createEmptyFile(atPath: outputFileURL) else {
            debugLog("File not created.")
            return nil
        }
        
        guard cryptoManager.encryptFile(at: filePath, outputTo: outputFileURL) else {
            debugLog("Encryption failed \(String(describing: vaultFileId))", level: .debug, space: .crypto)
            return nil
        }
        
        deleteTmpFiles(files: [filePath])
        return true
    }
    
    func loadFileData(file vaultFile: VaultFileDB) -> Data? {
        
        debugLog("\(vaultFile)", space: .files)
        
        guard let fileURL = loadVaultFileToURL(file: vaultFile) else {
            return nil
        }
        
        let data = fileManager.contents(atPath: fileURL)
        
        deleteFiles(files: [fileURL])
        
        return data
    }
    
    func loadFileToURL(fileName: String, fileExtension: String, identifier: String) -> URL? {
        let tmpFileURL = createTempFileURL(pathExtension: fileExtension)
        
        guard (fileManager.createEmptyFile(atPath: tmpFileURL)) else {
            debugLog("File not created.")
            return nil
        }
        
        let inputFileURL = containerURL(for: identifier)
        
        guard cryptoManager.decryptFile(at: inputFileURL, outputTo: tmpFileURL) else {
            return nil
        }
        
        return tmpFileURL
    }
    
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL? {
        loadVaultFileToURL(file: vaultFile,withSubFolder: false)
    }
    
    func loadVaultFileToURLAsync(file: ReportVaultFile,withSubFolder: Bool = false) async -> URL? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.loadVaultFileToURL(file: file, withSubFolder: withSubFolder)
                continuation.resume(returning: result)
            }
        }
    }
    
    func loadVaultFileToURLAsync(file: VaultFileDB,withSubFolder: Bool = false) async -> URL? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.loadVaultFileToURL(file: file, withSubFolder: withSubFolder)
                continuation.resume(returning: result)
            }
        }
    }


    func loadVaultFileToURL(file vaultFile: VaultFileDB, withSubFolder: Bool = false) -> URL? {
        
        let tmpFileURL = createTempFileURL(fileName: vaultFile.name ,pathExtension: vaultFile.fileExtension, withSubFolder: withSubFolder)
        
        if withSubFolder {
            fileManager.createDirectory(atPath: tmpFileURL.deletingLastPathComponent())
        }
        
        guard (fileManager.createEmptyFile(atPath: tmpFileURL)) else {
            debugLog("File not created.")
            return nil
        }
        
        guard let fileId = vaultFile.id else {
            return nil
        }
        
        let inputFileURL = containerURL(for: fileId)
        
        guard cryptoManager.decryptFile(at: inputFileURL, outputTo: tmpFileURL) else {
            return nil
        }
        
        return tmpFileURL
    }
    
    func getDescriptionFileUrl(content:String,fileName:String) -> URL? {
        
        let fileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: false, encoding: .utf8)
            debugLog("fileURL")
            return fileURL
        } catch {
            debugLog("Failed to write to file: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL] {
        
        var tmpUrlArray : [URL] = []
        
        vaultFiles.forEach { vaultFile in
            if vaultFile.type != .directory {
                guard let url = self.loadVaultFileToURL(file: vaultFile) else { return }
                tmpUrlArray.append(url)
            }
        }
        return tmpUrlArray
    }
    
    func loadFileDataOld(fileName: String?) -> Data? {
        guard let fileId = fileName else { return nil}
        
        debugLog("\(fileId)", space: .files)
        
        let fileURL = containerURL(for: fileId)
        
        guard let encryptedData = fileManager.contents(atPath: fileURL) else {
            return nil
        }
        return cryptoManager.decrypt(encryptedData)
    }
    
    func loadVaultFileToURLOld(file vaultFile: VaultFileDB) -> URL? {
        
        guard let data = self.loadFileDataOld(fileName: vaultFile.id) else { return nil }
        
        let tmpFileURL = createTempFileURL(pathExtension: vaultFile.fileExtension)
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }

    func extract(from inputFileURL: URL, offsetSize: Int) throws -> URL {

        guard fileManager.fileExists(filePath: inputFileURL.path) else {
            throw RuntimeError("Input file does not exist")
        }

        guard offsetSize >= 0 else {
            throw RuntimeError("Invalid offset (negative)")
        }

        guard let fileSize = fileManager.sizeOfFile(atPath: inputFileURL.path) else {
            throw RuntimeError("Could not get input file size")
        }

        guard offsetSize <= fileSize else {
            throw RuntimeError("Invalid offset (beyond EOF)")
        }

        let outputURL = createTempFileURL(pathExtension: inputFileURL.pathExtension)

        if fileManager.fileExists(filePath: outputURL.path) {
            fileManager.removeItem(at: outputURL)
        }

        _ = fileManager.createEmptyFile(atPath: outputURL)

        let inputHandle = try FileHandle(forReadingFrom: inputFileURL)
        defer { try? inputHandle.close() }

        let outputHandle = try FileHandle(forWritingTo: outputURL)
        defer { try? outputHandle.close() }

        try inputHandle.seek(toOffset: UInt64(offsetSize))

        let chunkSize = 1 * 1024 * 1024
        while true {
            if let data = try inputHandle.read(upToCount: chunkSize), !data.isEmpty {
                try outputHandle.write(contentsOf: data)
            } else {
                break
            }
        }

        return outputURL
    }
    
    func saveDataToTempFile(data: Data?, pathExtension: String?) -> URL? {
        self.saveDataToTempFile(data: data, fileName: nil, pathExtension: pathExtension)
    }
    
    func saveDataToTempFile(data: Data?, fileName: String?) -> URL? {
        self.saveDataToTempFile(data: data, fileName:fileName , pathExtension: nil )
    }
    
    func saveDataToTempFile(data: Data?, fileName: String?, pathExtension: String?) -> URL? {
        let tmpFileURL = self.createTempFileURL(fileName: fileName, pathExtension: pathExtension)
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func createTempFileURL(pathExtension: String) -> URL {
        self.createTempFileURL(fileName: nil, pathExtension: pathExtension)
    }
    
    func createTempFileURL(fileName: String?) -> URL {
        self.createTempFileURL(fileName: fileName, pathExtension: nil)
    }
    
    func createTempFileURL(fileName: String? , pathExtension: String?, withSubFolder: Bool = false) -> URL {
        let fileName = fileName ?? "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))"
        let subFolder = withSubFolder ? "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))" : ""
        
        let pathComponent = withSubFolder ? subFolder + "/" + fileName : fileName
        
        return URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(pathComponent).appendingPathExtension(pathExtension ?? "")
    }
    
    func deleteAllVaultFilesFromDevice() {
        debugLog("", space: .files)
        fileManager.removeItem(at: containerURL)
    }
    
    func deleteVaultFile(filesIds: [String]) {
        filesIds.forEach { fileId in
            debugLog("\(fileId)", space: .files)
            let fileURL = containerURL(for: fileId)
            fileManager.removeItem(at: fileURL)
        }
    }
    
    func clearTmpDirectory() {
        
        fileManager.removeContainerDirectory(directoryPath: NSTemporaryDirectory())
    }
    
    func deleteContainerDirectory() {
        
        let urlPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let fileName = fileManager.contentsOfDirectory(atPath: urlPath)
        
        fileManager.removeContainerDirectory(fileName: fileName, paths: urlPath)
    }
    
    func deleteRootFile() {
        let rootFileURL = containerURL(for: self.rootFileName)
        fileManager.removeItem(at: rootFileURL)
    }
    
    func rootIsExist() -> Bool {
        let rootFileURL = containerURL(for: self.rootFileName)
        return fileManager.fileExists(filePath: rootFileURL.getPath())
    }
    
    func deleteFiles(files: [URL]) {
        files.forEach { url in
            fileManager.removeItem(at: url)
        }
    }
    
    func deleteTmpFiles(files: [URL]) {
        files.forEach { url in
            if NSTemporaryDirectory() == url.deletingLastPathComponent().getPath() {
                fileManager.removeItem(at: url)
            }
        }
    }
    
    
    private func containerURL(for containerName: String) -> URL {
        return containerURL.appendingPathComponent(containerName)
    }
    
    private var containerURL: URL {
        
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(containerPath)
        return url
    }
    
    func fileExists(at filePath: String) -> Bool {
        fileManager.fileExists(filePath: filePath)
    }
    
    func isReadableFile(at filePath: String) -> Bool {
        fileManager.isReadableFile(filePath: filePath)
    }

}

//  VaultManager extension contains the methods used for authentication

extension VaultManager {
    
    func keysInitialized() -> Bool {
        return self.cryptoManager.keysInitialized()
    }
    
    func login(password:String?) -> AnyPublisher<Bool,Never> {
        
        return Deferred {
            Future <Bool,Never> {  [weak self] promise in
                guard let self = self else { return }
                
                do {
                    guard let _ = try self.recoverKey(password: password)?.getString() else { return promise(.success(false))  }
                    promise(.success(true))
                }
                catch let error {
                    debugLog(error)
                    promise(.success(false))
                    
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func recoverKey( password:String? = nil) throws -> SecKey?  {
        return cryptoManager.recoverKey(.PRIVATE, password: password)
    }
    
    func initKeys(_ type: PasswordTypeEnum, password:String) {
        do {
            try cryptoManager.initKeys(type, password: password)
            guard let key = try self.recoverKey(password: password)?.getString() else { return }
            onSuccessLock.send(key)
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
    
    func initialize() throws {
        fileManager.createDirectory(atPath: containerURL)
    }
}

//  VaultManager extension contains the methods used for merging root files to vault db

extension VaultManager {
    
    func getFilesToMergeToDatabase() -> [VaultFileDetailsToMerge] {
        guard let root = self.load(name: self.rootFileName) else {return []}
        var vaultFileResult : [VaultFileDetailsToMerge] = []
        getFiles(root: root, vaultFileResult: &vaultFileResult)
        return vaultFileResult
    }
    
    func getFiles(root: VaultFile, vaultFileResult: inout [VaultFileDetailsToMerge], parentId: String? = nil) {
        
        root.files.forEach { file in
            
            let vaultFile = VaultFileDB(vaultFile:file)
            vaultFileResult.append(VaultFileDetailsToMerge(vaultFileDB: vaultFile,parentId: parentId,oldId: file.id))
            if file.type == .folder {
                getFiles(root: file, vaultFileResult: &vaultFileResult, parentId: file.containerName)
            }
        }
    }
    
    // To decrypt root
    
    private func load(name: String) -> VaultFile? {
        debugLog("\(name)", space: .files)
        
        let decoder = JSONDecoder()
        
        guard let decryptedData = self.loadFileDataOld(fileName: name) else { return nil}
        
        do {
            return try decoder.decode(VaultFile.self, from: decryptedData)
            
        } catch let error {
            debugLog(error)
        }
        return nil
    }
}
