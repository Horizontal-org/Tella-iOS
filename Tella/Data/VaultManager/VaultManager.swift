//
//  Copyright © 2021 INTERNEWS. All rights reserved.
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

    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL? {

        let tmpFileURL = createTempFileURL(pathExtension: vaultFile.fileExtension)
        
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

    func extract(from inputFileURL: URL, offsetSize:Int)   {

        do {
            
            // Open the file in read-write mode
            let fileHandle = try FileHandle(forUpdating: inputFileURL)

            // Move the file pointer to the start offset
            try fileHandle.seek(toOffset: UInt64(offsetSize))

            // Read the content after the subrange
            let remainingData = fileHandle.readDataToEndOfFile()

            try fileHandle.seek(toOffset: 0)

            // Write back the content after the subrange
            fileHandle.write(remainingData)

            // Truncate the file to the new size
            fileHandle.truncateFile(atOffset: UInt64(remainingData.count))

            // Close the file handle
            fileHandle.closeFile()

        } catch let error {
            debugLog(error)
        }
    }

    func saveDataToTempFile(data: Data?, pathExtension: String) -> URL? {
        self.saveDataToTempFile(data: data, fileName: nil, pathExtension: pathExtension)
    }
    
    func saveDataToTempFile(data: Data?, fileName: String?, pathExtension: String) -> URL? {
        let tmpFileURL = self.createTempFileURL(pathExtension: pathExtension)
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))
                
        else {
            return nil
        }
        return tmpFileURL
    }
    
    func createTempFileURL(pathExtension: String) -> URL {
        self.createTempFileURL(fileName: nil, pathExtension: pathExtension)
    }
    
    func createTempFileURL(fileName: String?, pathExtension: String) -> URL {
        let fileName = fileName ?? "\(Int(Date().timeIntervalSince1970))"
        return URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(fileName).appendingPathExtension(pathExtension)
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
