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
    func login(serverUrl: String, username: String, password: String) async throws -> String
    func checkServer(serverUrl: String) async throws
    func createFolder(folderName: String, server:NextcloudServerModel?) async throws
    func uploadReport(report:NextcloudReportToSend) -> AnyPublisher<NextcloudUploadResponse,APIError>
    func pauseAllUploads()
}

enum NextcloudUploadResponse {
    case initial
    case progress(progressInfo: NextcloudUploadProgressInfo)
    case createReport
    case descriptionSent
    case nameUpdated(newName:String)
    case folderRecreated
}

class NextcloudRepository: NextcloudRepositoryProtocol {
    
    private let kRemotePhpFiles = "remote.php/dav/files/"
    private let kchunkSize = 1024 * 1024
    private let ktimeout = TimeInterval(60)
    
    private var subscribers = Set<AnyCancellable>()
    private var uploadTasks: [String?:URLSessionTask] = [:]
    private var shouldPause : Bool = false
    private let networkStatusSubject = PassthroughSubject<Bool, Never>()
    private let networkMonitor: NetworkMonitor
    private var server: NextcloudServerModel?
    
    private var rootFolderURL : String? {
        guard let server else { return nil }
        return server.url.slash() + self.kRemotePhpFiles + server.userId.slash() + (server.rootFolder?.slash() ?? "")
    }
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            self.networkStatusSubject.send(isConnected)
            if (!isConnected) {
                self.pauseAllUploads()
            }
        }).store(in: &subscribers)
    }
    
    private func setUp(server:NextcloudServerModel) {
        self.server = server
        NextcloudKit.shared.setup(account: server.username,
                                  user: server.username,
                                  userId: server.userId ,
                                  password: server.password,
                                  urlBase: server.url)
    }
    
    func checkServer(serverUrl: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.checkServer(serverUrl: serverUrl) { result in
                if result == .success {
                    continuation.resume()
                } else {
                    let error = APIError.convertNextcloudError(errorCode:result.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func login(serverUrl: String, username: String, password: String) async throws -> String {
        // NextcloudKit.shared.setup(delegate: self)
        NextcloudKit.shared.setup(account: username, user: username, userId: username , password: password, urlBase: serverUrl  )
        return try await withCheckedThrowingContinuation { continuation in
            NextcloudKit.shared.getUserProfile(account: "") { account, userProfile, data, result in
                if result == .success {
                    continuation.resume(returning: userProfile?.userId ?? "")
                } else {
                    let error = APIError.convertNextcloudError(errorCode:result.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func createFolder(folderName: String, server:NextcloudServerModel? = nil) async throws {
        
        if let server {
            self.setUp(server:server)
        }
        
        guard let rootFolderURL else { throw APIError.errorOccured }
        
        let fullURL = rootFolderURL + folderName
        
        debugLog(fullURL)
        
        try await withCheckedThrowingContinuation { continuation in
            
            NextcloudKit.shared.createFolder(serverUrlFileName: fullURL, account: "") { account, ocId, date, result in
                if result == .success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: APIError.nextcloudError(result.errorCode))
                }
            }
        }
    }
    
    func uploadReport(report:NextcloudReportToSend) -> AnyPublisher<NextcloudUploadResponse,APIError> {
        let subject = CurrentValueSubject<NextcloudUploadResponse, APIError>(.initial)
        submit(report: report, subject: subject)
        return subject.eraseToAnyPublisher()
    }
    
    private func submit(report:NextcloudReportToSend,subject: CurrentValueSubject<NextcloudUploadResponse, APIError>) {
        
        self.setUp(server:report.server)
        
        shouldPause = false
        
        Task {
            do {
                guard self.networkMonitor.isConnected else {
                    subject.send(completion:.failure(.noInternetConnection))
                    return
                }
                
                switch report.remoteReportStatus {
                    
                case .initial :
                    try await handleInitialStatus(report: report, subject: subject)
                    
                case .created:
                    try await handleCreatedStatus(report: report, subject: subject)
                    
                default:
                    break
                }
                
                if report.files.isEmpty {
                    subject.send(completion:.finished)
                }
                
                guard !shouldPause else { return }
                
                uploadFiles(report: report, subject: subject)
                
                monitorNetworkConnection(subject: subject)
                
            } catch let error as APIError {
                await handleError(error, report: report, subject: subject)
            }
        }
    }
    
    private func handleInitialStatus(report: NextcloudReportToSend, subject: CurrentValueSubject<NextcloudUploadResponse, APIError>) async throws {
        
        guard !shouldPause else { return }
        
        guard let folderName = try await createFileName(fileNameBase: report.folderName) else {
            subject.send(completion:.failure(APIError.unexpectedResponse))
            return
        }
        
        subject.send(.nameUpdated(newName: folderName))
        
        guard !shouldPause else { return }
        
        try await createFolder(folderName: folderName)
        subject.send(.createReport)
        
        guard !shouldPause else { return }
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
        
    }
    
    private func handleCreatedStatus(report: NextcloudReportToSend, subject: CurrentValueSubject<NextcloudUploadResponse, APIError>) async throws {
        
        guard !shouldPause else { return }
        
        try await uploadDescriptionFile(report: report)
        subject.send(.descriptionSent)
    }
    
    private func uploadFiles(report: NextcloudReportToSend, subject: CurrentValueSubject<NextcloudUploadResponse, APIError>)   {
        report.files.forEach { file in
            uploadFileInChunks(metadata: file, rootFolder: report.server.rootFolder ?? "")
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { result in
                    subject.send(.progress(progressInfo: result))
                }).store(in: &subscribers)
        }
        
    }
    
    private func monitorNetworkConnection(subject: CurrentValueSubject<NextcloudUploadResponse, APIError>) {
        self.networkStatusSubject
            .filter { !$0 }
            .first()
            .sink { _ in
                subject.send(completion: .failure(.noInternetConnection))
            }
            .store(in: &self.subscribers)
    }
    
    private func handleError(_ error: APIError, report: NextcloudReportToSend, subject: CurrentValueSubject<NextcloudUploadResponse, APIError>) async {
        debugLog(error)
        switch error {
        case .nextcloudError(let code) where code == NcHTTPErrorCodes.nonExistentFolder.rawValue:
            try? await createFolder(folderName: "") // This will create a folder with the rootname
            subject.send(.folderRecreated)
            self.submit(report: report, subject: subject) // re-upload the report
        default:
            subject.send(completion:.failure(error))
        }
    }
    
    private func uploadDescriptionFile(report:NextcloudReportToSend) async throws {
        
        guard let descriptionFileUrl = report.descriptionFileUrl else { return }
        
        guard let rootFolderURL else { throw APIError.errorOccured }
        
        let fullURL = rootFolderURL + report.folderName.slash() + descriptionFileUrl.lastPathComponent
        
        try await withCheckedThrowingContinuation { continuation in
            
            NextcloudKit.shared.upload(serverUrlFileName: fullURL,
                                       fileNameLocalPath: descriptionFileUrl.getPath(),
                                       dateCreationFile: Date(),
                                       dateModificationFile: Date(), account: "", completionHandler: { account, ocId, etag, date, size, allHeaderFields, afError, nkError in
                
                if nkError == .success {
                    continuation.resume()
                } else {
                    let error = APIError.convertNextcloudError(errorCode:nkError.errorCode)
                    continuation.resume(throwing: error)
                }
            })
        }
    }
    
    private func uploadFileInChunks(metadata:NextcloudMetadata, rootFolder:String) -> CurrentValueSubject<NextcloudUploadProgressInfo,APIError> {
        
        let progressInfo = NextcloudUploadProgressInfo(fileId: metadata.fileId, status: FileStatus.partialSubmitted)
        
        let subject = CurrentValueSubject<NextcloudUploadProgressInfo, APIError>(progressInfo)
        
        Task {
            
            let options = NKRequestOptions(queue: NextcloudKit.shared.nkCommonInstance.backgroundQueue)
            
            let remoteFolderName = "/" + rootFolder.slash() + metadata.remoteFolderName
            
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
                progressInfo.error = APIError.convertNextcloudError(errorCode:error.errorCode)
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
                    debugLog("The file for sending could not be created")
                    continuation.resume(throwing: APIError.unexpectedResponse)
                }
            }
        }
    }
    
    private func fileExists(serverUrlFileName: String) async throws -> Bool?  {
        
        let option = NKRequestOptions(timeout: ktimeout, queue: NextcloudKit.shared.nkCommonInstance.backgroundQueue)
        
        return try await withCheckedThrowingContinuation({ continuation in
            NextcloudKit.shared.readFileOrFolder(serverUrlFileName: serverUrlFileName,
                                                 depth: "0",
                                                 requestBody: NextcloudConstants.filesRequestBody.data(using: .utf8), account: "",
                                                 options: option) {
                account, files, _, error in
                
                if error == .success, let _ = files.first {
                    continuation.resume(returning: true)
                } else if error.errorCode == HTTPErrorCodes.notFound.rawValue {
                    continuation.resume(returning: false)
                } else {
                    let error = APIError.convertNextcloudError(errorCode:error.errorCode)
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    private func createFileName(fileNameBase: String) async throws -> String? {
        
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
            
            guard let rootFolderURL else { throw APIError.errorOccured }
            
            let fullURL = rootFolderURL + resultFileName
            
            let fileExists = try await fileExists(serverUrlFileName: fullURL)
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
