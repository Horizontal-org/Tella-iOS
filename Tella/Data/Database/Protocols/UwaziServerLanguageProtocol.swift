//
//  UwaziServerLanguageProtocol.swift
//  Tella
//
//  Created by Robert Shrestha on 9/11/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol UwaziServerLanguageProtocol {
    func createLanguageTableForUwazi()
    func addUwaziLocale(locale: UwaziLocale) -> Int?
    func getUwaziLocale(serverId: Int) throws -> UwaziLocale?
    func getAllUwaziLocale() throws -> [UwaziLocale]
    func deleteUwaziLocale(serverId : Int) throws
    func deleteAllUwaziLocale() throws -> Int
}
