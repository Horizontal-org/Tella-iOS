//
//  NativeOuisyncClient.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import OuisyncLib

actor NativeOuisyncClient: OuisyncServing {
    
    private var service: OuisyncService?
    private var session: Session?
    private var repositories: [String: Repository] = [:]
    private var deviceLocalSecretKey: SecretKey?
    
    private let localSecretStore = OuisyncLocalSecretStore()
    
    init() {}
    
    func start() async throws {
        guard session == nil else { return }
        try await startService()
    }
    
    private func startService() async throws {
        let fileManager = FileManager.default
        let configDir = try fileManager.createApplicationSupportDirectory(withPath: "TellaOuisync/config").path
        let storeDir = try fileManager.createApplicationSupportDirectory(withPath: "TellaOuisync/store").path
        
        OuisyncService.initLog()
        
        do {
            service = try await OuisyncService.start(configDir: configDir)
        } catch {
            
        }
        
        do {
            let session = try await Session.create(configPath: configDir)
            self.session = session
            try await session.setStoreDirs([storeDir])
            
            try await session.bindNetwork(["quic/0.0.0.0:0", "quic/[::]:0"])
            try await session.setLocalDiscoveryEnabled(true)
            try await session.setPortForwardingEnabled(false)
            
        } catch {
            await session?.close()
            session = nil
            try? await service?.stop()
            service = nil
            throw error
        }
    }
    
    func listRepositories() async throws -> [OuisyncRepositoryInfo] {
        let session = try requireSession()
        repositories = try await session.listRepositories()
        var infos: [OuisyncRepositoryInfo] = []
        for (name, repo) in repositories {
            try await ensureLocalSecret(for: repo)
            try await repo.setSyncEnabled(true)
            let shortName = (try? await repo.getShortName()) ?? ""
            infos.append(OuisyncRepositoryInfo(name: name, shortName: shortName))
        }
        return infos
        
    }
    
    func importRepository(shareToken: String) async throws {
        let session = try requireSession()
        let token = try await session.validateShareToken(shareToken.trimmed())
        let suggestedName = try await session.getShareTokenSuggestedName(token).trimmed()
        let repositoryName = suggestedName.isEmpty ? "Repository" : suggestedName
        let readSecret = try await storedSetLocalSecret()

        _ = try await session.createRepository(
            repositoryName,
            readSecret,
            nil,
            token,
            true,
            false,
            false
        )
    }
    
    func listEntries(repositoryName: String) async throws -> [OuisyncEntry] {
        let repo = try requireRepository(repositoryName)
        let entries = try await repo.readDirectory("")
        return entries.map { entry in
            OuisyncEntry(
                name: entry.name,
                path: entry.name.preffixedSlash(),
                isDirectory: entry.entryType == .directory
            )
        }
    }
    
    func exportFile(repositoryName: String, path: String, to destinationURL: URL) async throws {
        let repo = try requireRepository(repositoryName)
        let file = try await repo.openFile(path)
        do {
            let length = try await file.getLength()
            try await waitUntilSynced(repo, file, length: length)
            try await file.close()
        } catch {
            try? await file.close()
            throw error
        }
        
        try await requireSession().copy(repositoryName, path, nil, destinationURL.path)
    }
    
    private func deviceSecretKey() async throws -> SecretKey {
        if let existing = try existingDeviceSecretKey() {
            return existing
        }
        
        let key = try await requireSession().generateSecretKey()
        
        if let existing = try existingDeviceSecretKey() {
            return existing
        }
        guard localSecretStore.saveSecretKey(key.value) else {
            throw RuntimeError("Could not access the Ouisync key on this device")
        }
        deviceLocalSecretKey = key
        return key
    }
    
    private func existingDeviceSecretKey() throws -> SecretKey? {
        if let deviceLocalSecretKey {
            return deviceLocalSecretKey
        }
        guard let data = localSecretStore.recoverSecretKey() else {
            return nil
        }
        guard let key = try? SecretKey(rawRepresentation: data) else {
            throw RuntimeError("Could not access the Ouisync key on this device")
        }
        deviceLocalSecretKey = key
        return key
    }
    
    private func storedSetLocalSecret() async throws -> SetLocalSecret {
        let key = try await deviceSecretKey()
        let salt = try await requireSession().generatePasswordSalt()
        return .keyAndSalt(key: key, salt: salt)
    }
    
    private func ensureLocalSecret(for repo: Repository) async throws {
        guard let key = try existingDeviceSecretKey() else {
            throw RuntimeError("Could not access the Ouisync key on this device")
        }
        try await repo.setAccessMode(.read, .secretKey(key))
    }
    
    private func requireSession() throws -> Session {
        guard let session else {
            throw RuntimeError("Ouisync is not started yet")
        }
        return session
    }
    
    private func requireRepository(_ name: String) throws -> Repository {
        guard let repo = repositories[name] else {
            throw RuntimeError("Repository \"\(name)\" was not found")
        }
        return repo
    }
    
    private func waitUntilSynced(_ repo: Repository, _ file: File, length: UInt64) async throws {
        let updates = try await repo.subscribe()
        if try await file.getProgress() >= length { return }
        
        for await _ in updates {
            if try await file.getProgress() >= length { return }
        }
        throw RuntimeError("The file stopped syncing before the download finished")
    }
}
