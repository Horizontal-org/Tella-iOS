//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class TellaData {
    
    var database : TellaDataBase?
    
    init(key: String?) {
        self.database = TellaDataBase(key: key)
    }
    
    func addServer(server : Server) throws -> Int {
        
        guard let database = database else {
            throw SqliteError()
        }
        return try database.addServer(server: server)
        
    }
    
    func updateServer(server : Server) throws -> Int {
        
        guard let database = database else {
            throw SqliteError()
        }
        return try database.updateServer(server: server)
        
    }
    
    func deleteServer(server : Server) throws -> Int {
        
        guard let database = database else {
            throw SqliteError()
        }
        return try database.deleteServer(server: server)
        
    }
    
    func getServers() -> [Server] {
        database?.getServer() ?? []
    }

    func getReports()  {
        
    }
    
    func addReport() {
        
    }
    
    func updateReport()   {
        
    }
    
}
