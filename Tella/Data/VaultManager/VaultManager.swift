//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SwiftUI
import Combine
import Security

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
        defer {
            deleteTmpFiles(files: [filePath])
        }
        
        let outputFileURL = containerURL(for: vaultFileId)
        
        guard fileManager.createEmptyFile(atPath: outputFileURL) else {
            debugLog("File not created.")
            return nil
        }
        
        guard cryptoManager.encryptFile(at: filePath, outputTo: outputFileURL) else {
            debugLog("Encryption failed \(String(describing: vaultFileId))", level: .debug, space: .crypto)
            return nil
        }
        
        return true
    }
    
    func loadFileData(file vaultFile: VaultFileDB) -> Data? {
        guard let fileURL = loadVaultFileToURL(file: vaultFile) else {
            return nil
        }
        
        defer {
            securelyDeleteTempFile(at: fileURL)
        }
        
        return fileManager.contents(atPath: fileURL)
    }
    
    func loadFileToURL(fileName: String, fileExtension: String, identifier: String) -> URL? {
        let tmpFileURL = createTempFileURL(pathExtension: fileExtension)
        
        guard (fileManager.createEmptyFile(atPath: tmpFileURL)) else {
            debugLog("File not created.")
            return nil
        }
        applyProtection(to: tmpFileURL)
        
        let inputFileURL = containerURL(for: identifier)
        
        guard cryptoManager.decryptFile(at: inputFileURL, outputTo: tmpFileURL) else {
            securelyDeleteTempFile(at: tmpFileURL)
            return nil
        }
        
        return tmpFileURL
    }
    
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL? {
        loadVaultFileToURL(file: vaultFile, withSubFolder: false)
    }
    
    func loadVaultFileToURL(file vaultFile: VaultFileDB, withSubFolder: Bool) -> URL? {
        loadVaultFileToURL(file: vaultFile, withSubFolder: withSubFolder, subFolderName: nil)
    }
    
    func loadVaultFileToURLAsync(file: ReportVaultFile,
                                 withSubFolder: Bool = false,
                                 subFolderName: String? = nil
    ) async -> URL? {
        
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.loadVaultFileToURL(
                    file: file,
                    withSubFolder: withSubFolder,
                    subFolderName: subFolderName
                )
                continuation.resume(returning: result)
            }
        }
    }
    func loadVaultFileToURLAsync(
        file: VaultFileDB,
        withSubFolder: Bool = false,
        subFolderName: String? = nil
    ) async -> URL? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.loadVaultFileToURL(
                    file: file,
                    withSubFolder: withSubFolder,
                    subFolderName: subFolderName
                )
                continuation.resume(returning: result)
            }
        }
    }
    
    func loadVaultFileToURLAsync(file: ReportVaultFile) async -> URL? {
        await loadVaultFileToURLAsync(file: file, withSubFolder: false, subFolderName: nil)
    }
    
    func loadVaultFileToURLAsync(file: VaultFileDB) async -> URL? {
        await loadVaultFileToURLAsync(file: file, withSubFolder: false, subFolderName: nil)
    }
    
    func loadVaultFileToURL(
        file vaultFile: VaultFileDB,
        withSubFolder: Bool = false,
        subFolderName: String? = nil
    ) -> URL? {
        
        let tmpFileURL = createTempFileURL(
            fileName: vaultFile.name,
            pathExtension: vaultFile.fileExtension,
            withSubFolder: withSubFolder,
            subFolderName: subFolderName
        )
        
        if withSubFolder || subFolderName != nil {
            fileManager.createDirectory(atPath: tmpFileURL.deletingLastPathComponent())
        }
        
        guard fileManager.createEmptyFile(atPath: tmpFileURL) else {
            debugLog("File not created.")
            return nil
        }
        
        applyProtection(to: tmpFileURL)
        
        guard let fileId = vaultFile.id else {
            securelyDeleteTempFile(at: tmpFileURL)
            return nil
        }
        
        let inputFileURL = containerURL(for: fileId)
        
        guard cryptoManager.decryptFile(at: inputFileURL, outputTo: tmpFileURL) else {
            securelyDeleteTempFile(at: tmpFileURL)
            return nil
        }
        
        return tmpFileURL
    }
    func getDescriptionFileUrl(content: String, fileName: String) -> URL? {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: false, encoding: .utf8)
            applyProtection(to: fileURL)
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
        
        guard (fileManager.createFile(atPath: tmpFileURL, contents: data))else {
            return nil
        }
        applyProtection(to: tmpFileURL)
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
            securelyDeleteTempFile(at: outputURL)
        }
        
        guard fileManager.createEmptyFile(atPath: outputURL) else {
            throw RuntimeError("Could not create output file")
        }
        
        applyProtection(to: outputURL)
        
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
        
        guard fileManager.createFile(atPath: tmpFileURL, contents: data) else {
            return nil
        }
        
        applyProtection(to: tmpFileURL)
        
        return tmpFileURL
    }
    
    private func applyProtection(to url: URL) {
        do {
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
        } catch {
            debugLog("Failed to apply file protection to \(url.lastPathComponent): \(error)")
        }
    }
    
    func createTempFileURL(pathExtension: String) -> URL {
        self.createTempFileURL(fileName: nil, pathExtension: pathExtension)
    }
    
    func createTempFileURL(fileName: String?) -> URL {
        self.createTempFileURL(fileName: fileName, pathExtension: nil)
    }
    //    
    //    func createTempFileURL(fileName: String? , pathExtension: String?, withSubFolder: Bool = false) -> URL {
    //        let fileName = fileName ?? "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))"
    //        let subFolder = withSubFolder ? "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))" : ""
    //        
    //        let pathComponent = withSubFolder ? subFolder + "/" + fileName : fileName
    //        
    //        return URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent(pathComponent).appendingPathExtension(pathExtension ?? "")
    //    }
    func createTempFileURL(
        fileName: String?,
        pathExtension: String?,
        withSubFolder: Bool = false,
        subFolderName: String? = nil
    ) -> URL {
        
        let fileName = fileName ?? "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))"
        
        let subFolder: String
        
        if let subFolderName, !subFolderName.isEmpty {
            subFolder = subFolderName
        } else if withSubFolder {
            subFolder = "\(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))"
        } else {
            subFolder = ""
        }
        
        let pathComponent = subFolder.isEmpty ? fileName : "\(subFolder)/\(fileName)"
        
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(pathComponent)
            .appendingPathExtension(pathExtension ?? "")
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
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        
        guard let enumerator = FileManager.default.enumerator(
            at: tempURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            debugLog("Failed to enumerate temp directory")
            return
        }
        
        var fileURLs: [URL] = []
        var directoryURLs: [URL] = []
        
        for case let url as URL in enumerator {
            do {
                let values = try url.resourceValues(forKeys: [.isDirectoryKey])
                if values.isDirectory == true {
                    directoryURLs.append(url)
                } else {
                    fileURLs.append(url)
                }
            } catch {
                debugLog("Failed to inspect \(url.path): \(error)")
            }
        }
        
        // Securely delete files first
        fileURLs.forEach { url in
            securelyDeleteTempFile(at: url)
        }
        
        // Remove directories after files, deepest first
        directoryURLs
            .sorted { $0.path.count > $1.path.count }
            .forEach { url in
                fileManager.removeItem(at: url)
            }
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
            if isInsideTemporaryDirectory(url) {
                securelyDeleteTempFile(at: url)
            } else {
                fileManager.removeItem(at: url)
            }
        }
    }
    
    func deleteTmpFiles(files: [URL]) {
        files.forEach { url in
            guard isInsideTemporaryDirectory(url) else { return }
            securelyDeleteTempFile(at: url)
        }
    }
    
    func deleteTmpFilesWithParents(files: [URL]) {
        let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).standardizedFileURL
        files.forEach { url in
            guard isInsideTemporaryDirectory(url) else { return }
            securelyDeleteTempFile(at: url)
            let parent = url.deletingLastPathComponent().standardizedFileURL
            guard parent.path.hasPrefix(tempRoot.path + "/") else { return }
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: parent,
                    includingPropertiesForKeys: nil
                )
                if contents.isEmpty {
                    try FileManager.default.removeItem(at: parent)
                }
            } catch {
                debugLog("Failed to remove temp parent directory \(parent.path): \(error)")
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
    
    /// Returns true only if the file is inside NSTemporaryDirectory().
    func isInsideTemporaryDirectory(_ url: URL) -> Bool {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .standardizedFileURL
        let fileURL = url.standardizedFileURL
        
        return fileURL.path.hasPrefix(tempURL.path + "/") || fileURL.path == tempURL.path
    }
    
    
    /// Overwrites file contents before deletion
    
    @discardableResult
    func wipeFileContents(at url: URL) -> Bool {
        guard fileManager.fileExists(filePath: url.path) else { return true }
        
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = (attrs[.size] as? NSNumber)?.uint64Value ?? 0
            guard fileSize > 0 else { return true }
            
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            
            try handle.seek(toOffset: 0)
            
            let chunkSize = 64 * 1024
            var randomChunk = Data(count: chunkSize)
            defer { randomChunk.secureWipe() }
            
            var remaining = fileSize
            
            while remaining > 0 {
                let writeCount = Int(min(UInt64(chunkSize), remaining))
                try fillWithSecureRandomBytes(&randomChunk, count: writeCount)
                try handle.write(contentsOf: randomChunk.prefix(writeCount))
                remaining -= UInt64(writeCount)
            }
            
            try handle.synchronize()
            return true
        } catch {
            debugLog("wipeFileContents failed for \(url.lastPathComponent): \(error)")
            return false
        }
    }
    
    private func fillWithSecureRandomBytes(_ buffer: inout Data, count: Int) throws {
        try buffer.withUnsafeMutableBytes { mutableBytes in
            guard let baseAddress = mutableBytes.baseAddress, count > 0 else { return }
            
            let status = SecRandomCopyBytes(kSecRandomDefault, count, baseAddress)
            guard status == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
            }
        }
    }
    /// Temp only delete path: overwrite first, then remove.
    func securelyDeleteTempFile(at url: URL) {
        guard isInsideTemporaryDirectory(url) else {
            debugLog("Refusing secure temp delete outside temp dir: \(url.path)")
            fileManager.removeItem(at: url)
            return
        }
        
        do {
            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
            
            if values.isDirectory == true {
                fileManager.removeItem(at: url)
                return
            }
        } catch {
            debugLog("Failed to inspect temp item \(url.path): \(error)")
        }
        
        _ = wipeFileContents(at: url)
        fileManager.removeItem(at: url)
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
