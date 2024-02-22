//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

protocol VaultManagerInterface {
    
    var tellaData : TellaData? { get set }
    var key : String? { get }
    var shouldCancelImportAndEncryption : CurrentValueSubject<Bool,Never> { get set }
    var onSuccessLock : PassthroughSubject<String,Never> { get set }
    func rootIsExist() -> Bool
    
    func keysInitialized() -> Bool
    func login(password:String?) -> AnyPublisher<Bool,Never>
    func initKeys(_ type: PasswordTypeEnum, password:String)
    func updateKeys(_ type: PasswordTypeEnum, newPassword:String, oldPassword:String)
    func getPasswordType() -> PasswordTypeEnum
    func initialize(with key:String?) throws
    
    func getFilesToMergeToDatabase() -> [VaultFileDetailsToMerge]
    func loadFileData(file vaultFile: VaultFileDB) -> Data?
    func loadVaultFileToURL(file vaultFile: VaultFileDB) -> URL?
    func loadFileToURL(fileName: String, fileExtension: String, identifier: String) -> URL?
    func loadVaultFilesToURL(files vaultFiles: [VaultFileDB]) -> [URL]
    func extract(from inputFileURL: URL, offsetSize:Int)
    func loadVaultFileToURLOld(file vaultFile: VaultFileDB) -> URL?
    func loadFileDataOld(fileName: String?) -> Data?

    func save(_ filePath: URL, vaultFileId: String?) -> Bool?
    
    func saveDataToTempFile(data: Data?, pathExtension: String) -> URL?
    func saveDataToTempFile(data: Data?, fileName: String?, pathExtension: String) -> URL?
    
    func createTempFileURL(pathExtension: String) -> URL
    func createTempFileURL(fileName: String?, pathExtension: String) -> URL
    
    func deleteAllVaultFilesFromDevice()
    func deleteVaultFile(filesIds: [String])
    func deleteFiles(files: [URL])
    func deleteTmpFiles(files: [URL])
    func clearTmpDirectory()
    func deleteContainerDirectory()
    func deleteRootFile()
}
