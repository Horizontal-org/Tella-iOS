//
//  UwaziServerLanguageProtocol.swift
//  Tella
//
//  Created by Robert Shrestha on 9/11/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol UwaziServerLanguageProtocol {
    func createUwaziServerTable()
    
    func addUwaziServer(server: UwaziServer) -> Int?
    
    func getUwaziServer(serverId: Int) throws -> UwaziServer?
    
    func parseUwaziServer(dictionary : [String:Any] ) -> UwaziServer 
}
