//
//  NextCloudRepository.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import NextcloudKit
import Combine

protocol NextcloudRepositoryProtocol {
    func login(serverUrl: String, username: String, password: String) async throws
    func checkServer(serverUrl: String) async throws
    func createFolder(serverUrl: String, folderName: String) async throws
    func uploadReport(report:NextcloudReportToSend) -> AnyPublisher<NextcloudUploadResponse,RuntimeError>
    func pauseAllUploads()
}

enum NextcloudUploadResponse {
    case initial
    case progress(progressInfo: NextcloudUploadProgressInfo)
    case createReport
    case descriptionSent
    case nameUpdated(newName:String)
}

class NextcloudRepository: NextcloudRepositoryProtocol {
    
    private let kRemotePhpFiles = "remote.php/dav/files/"
    private let kchunkSize = (1024 * 1024)
    private let ktimeout = TimeInterval(60)

    private var subscribers = Set<AnyCancellable>()
    private var uploadTasks: [String?:URLSessionTask] = [:]
    private var shouldPause : Bool = false
    
    // Those attributes must be removed from here
    private var userId = ""
    let configServerUrl = ""
    let configUsername = ""
    let configPassword = ""

    init() {
        // Setup should be checked if the server is already in Database or not
        setUp()
    }
    
    func setUp() {
        // Using 'configUsername', 'configServerUrl' and 'configServerUrl' from DB
        // We should check if server exist in database and retrieve data from DB
        NextcloudKit.shared.setup(account: self.configUsername, user: self.configUsername, userId: self.userId , password: self.configPassword, urlBase: self.configServerUrl  )
    }
    
    func checkServer(serverUrl: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.checkServer(serverUrl: serverUrl) { result in
                if result == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: APIError.httpCode(result.errorCode) )
                }
            }
        }
    }
    
    func login(serverUrl: String, username: String, password: String) async throws {
        // NextcloudKit.shared.setup(delegate: self)
        NextcloudKit.shared.setup(account: username, user: username, userId: username , password: password, urlBase: serverUrl  )
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.getUserProfile(account: "") { account, userProfile, data, result in
                if result == .success {
                    self.userId = userProfile?.userId ?? ""
                    continuation.resume()
                } else {
                    continuation.resume(throwing: APIError.httpCode(result.errorCode))
                }
            }
        }
    }
    
    
    func createFolder(serverUrl: String, folderName: String) async throws {
        let fullURL = serverUrl.slash() + self.kRemotePhpFiles + userId.slash() + folderName // This fullURL should be updated
        try await withCheckedThrowingContinuation { continuation in
            
            NextcloudKit.shared.createFolder(serverUrlFileName: fullURL, account: "") { account, ocId, date, result in
                if result == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: APIError.httpCode(result.errorCode))
                }
            }
        }
    }
    
    func uploadReport(report:NextcloudReportToSend) -> AnyPublisher<NextcloudUploadResponse,RuntimeError> {
        
        // setUp() must be removed from here
        self.setUp()
        
        shouldPause = false
        
        let subject = CurrentValueSubject<NextcloudUploadResponse, RuntimeError>(.initial)
        
        Task {
            do {
                
                switch report.remoteReportStatus {
                    
                case .initial,.unknown :
                    
                    guard !shouldPause else { return }
                    
                    guard let folderName = await createFileName(fileNameBase: report.folderName, serverUrl: report.serverUrl) else {
                        subject.send(completion:.failure(RuntimeError(LocalizableCommon.commonError.localized)))
                        return
                    }
                    
                    subject.send(.nameUpdated(newName: folderName))
                    
                    guard !shouldPause else { return }
                    
                    try await createFolder(serverUrl: report.serverUrl, folderName: folderName)
                    subject.send(.createReport)
                    
                    guard !shouldPause else { return }
                    
                    try await uploadDescriptionFile(report: report)
                    subject.send(.descriptionSent)
                    
                case .created:
                    guard !shouldPause else { return }
                    
                    try await uploadDescriptionFile(report: report)
                    subject.send(.descriptionSent)
                    
                default:
                    break
                }
                
                if report.files.isEmpty {
                    subject.send(completion:.finished)
                }
                
                guard !shouldPause else { return }
                
                report.files.forEach { file in
                    
                    uploadFileInChunks(metadata: file)
                        .sink(receiveCompletion: { _ in
                            
                        }, receiveValue: { result in
                            subject.send(.progress(progressInfo: result))
                        }).store(in: &subscribers)
                }
            } catch let error as RuntimeError {
                debugLog(error)
                subject.send(completion:.failure(error))
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func uploadDescriptionFile(report:NextcloudReportToSend) async throws {
        
        guard let descriptionFileUrl = report.descriptionFileUrl else { return }
        
        let fullURL = report.serverUrl + "/" + self.kRemotePhpFiles + userId  + "/" + report.folderName + "/" + descriptionFileUrl.lastPathComponent
        
        try await withCheckedThrowingContinuation { continuation in
            
            NextcloudKit.shared.upload(serverUrlFileName: fullURL,
                                       fileNameLocalPath: descriptionFileUrl.getPath(),
                                       dateCreationFile: Date(),
                                       dateModificationFile: Date(), account: "", completionHandler: { account, ocId, etag, date, size, allHeaderFields, afError, nkError in
                
                if nkError == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: RuntimeError(nkError.errorDescription))
                }
            })
        }
    }
    
    func uploadFileInChunks(metadata:NextcloudMetadata) -> CurrentValueSubject<NextcloudUploadProgressInfo,RuntimeError> {
        
        let progressInfo = NextcloudUploadProgressInfo(fileId: metadata.fileId, status: FileStatus.partialSubmitted)
        
        let subject = CurrentValueSubject<NextcloudUploadProgressInfo, RuntimeError>(progressInfo)
        
        Task {
            
            let options = NKRequestOptions(queue: NextcloudKit.shared.nkCommonInstance.backgroundQueue)
            
            let remoteFolderName = "/" + metadata.remoteFolderName
            
            if !metadata.chunkFiles.isEmpty {
                do {
                    
                    try await createChunks(directory: metadata.directory, fileName: metadata.fileName, chunkSize: kchunkSize)
                } catch {
                    progressInfo.status = .submissionError
                }
            }

            guard !shouldPause else { return }

            NextcloudKit.shared.uploadChunk(directory: metadata.directory,
                                            fileName: metadata.fileName,
                                            date: Date(),
                                            creationDate: Date(),
                                            serverUrl: remoteFolderName,
                                            chunkFolder: metadata.chunkFolder,
                                            filesChunk: metadata.chunkFiles,
                                            chunkSize: kchunkSize, account: "",
                                            options: options) { _ in
                
            } counterChunk: { _ in
            } start: { filesChunk in
                progressInfo.status = .partialSubmitted
                progressInfo.chunkFiles = filesChunk
                progressInfo.step = .start
                subject.send(progressInfo)
                
            } requestHandler: { request in
            } taskHandler: { task in
                subject.send(progressInfo)
                self.uploadTasks[metadata.fileId] = task
            } progressHandler: { totalBytesExpected, totalBytes, fractionCompleted in
                progressInfo.bytesSent = Int(totalBytes)
                progressInfo.step = .progress
                subject.send(progressInfo)
            } uploaded: { fileChunk in
                progressInfo.chunkFileSent = fileChunk
                progressInfo.step = .chunkSent
                subject.send(progressInfo)
                
            } completion : { account, filesChunk, file, afError, error in
                progressInfo.status = error == .success ? .submitted : .submissionError
                progressInfo.finishUploading = true
                progressInfo.step = .finished
                subject.send(progressInfo)
                self.uploadTasks.removeValue(forKey: metadata.fileId)
            }
        }
        return subject
    }
    
    private func createChunks(directory:String, fileName:String, chunkSize:Int) async throws  {
        
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.nkCommonInstance.chunkedFile(inputDirectory: directory, 
                                                             outputDirectory: directory,
                                                             fileName: fileName,
                                                             chunkSize: chunkSize,
                                                             filesChunk: []) { num in
            } counterChunk: { counter in
                
            } completion: { filesChunk in
                if !filesChunk.isEmpty {
                    continuation.resume()
                } else {
                    // The file for sending could not be created
                    let error = NKError(errorCode: NKError.chunkFilesNull, errorDescription: "_chunk_files_null_")
                    continuation.resume(throwing: RuntimeError(error.errorDescription))
                }
            }
        }
    }
    
    func fileExists(serverUrlFileName: String) async -> Bool?  {
        
        let requestBody =
        """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <d:propfind xmlns:d=\"DAV:\" xmlns:oc=\"http://owncloud.org/ns\" xmlns:nc=\"http://nextcloud.org/ns\">
            <d:prop></d:prop>
        </d:propfind>
        """

        let option = NKRequestOptions(timeout: ktimeout, queue: NextcloudKit.shared.nkCommonInstance.backgroundQueue)
        return await withUnsafeContinuation({ continuation in
            NextcloudKit.shared.readFileOrFolder(serverUrlFileName: serverUrlFileName,
                                                 depth: "0",
                                                 requestBody: requestBody.data(using: .utf8), account: "",
                                                 options: option) {
                account, files, _, error in

                if error == .success, let _ = files.first {
                    continuation.resume(returning: true)
                } else if error.errorCode == HTTPErrorCodes.notFound.rawValue {
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        })
    }
    

    
    func createFileName(fileNameBase: String, serverUrl: String) async -> String? {
        
        var exitLoop = false
        var resultFileName = fileNameBase
        
        func newFileName() {
            var name = NSString(string: resultFileName).deletingPathExtension
            let ext = NSString(string: resultFileName).pathExtension
            let characters = Array(name)
            if characters.count < 2 {
                if ext.isEmpty {
                    resultFileName = name + " 1"
                } else {
                    resultFileName = name + " 1" + "." + ext
                }
            } else {
                let space = characters[characters.count - 2]
                let numChar = characters[characters.count - 1]
                var num = Int(String(numChar))
                if space == " " && num != nil {
                    name = String(name.dropLast())
                    num = num! + 1
                    if ext.isEmpty {
                        resultFileName = name + "\(num!)"
                    } else {
                        resultFileName = name + "\(num!)" + "." + ext
                    }
                } else {
                    if ext.isEmpty {
                        resultFileName = name + " 1"
                    } else {
                        resultFileName = name + " 1" + "." + ext
                    }
                }
            }
        }
        
        while !exitLoop {
            
            let fullURL = serverUrl + "/" + self.kRemotePhpFiles + userId  + "/" + resultFileName // This fullURL should be updated
            
            let fileExists = await fileExists(serverUrlFileName: fullURL)
            guard let fileExists else { return nil}
            if fileExists {
                newFileName()
            } else {
                exitLoop = true
            }
        }
        return resultFileName
    }
    
    func pauseAllUploads() {
        shouldPause = true
        
        uploadTasks.forEach { $0.value.cancel() }
        uploadTasks.removeAll()
    }
    
}


 
