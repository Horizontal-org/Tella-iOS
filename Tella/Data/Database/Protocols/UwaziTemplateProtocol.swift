//
//  UwaziTemplateProtocol.swift
//  Tella
//
//  Created by Robert Shrestha on 9/11/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

protocol UwaziTemplateProtocol {
    func createTemplateTableForUwazi()
    func getUwaziTemplate(serverId: Int) throws -> CollectedTemplate?
    func getUwaziTemplate(templateId: Int?) throws -> CollectedTemplate?
    func getAllUwaziTemplate() throws -> [CollectedTemplate]
    func addUwaziTemplate(template: CollectedTemplate) -> Result<CollectedTemplate, Error>
    func deleteAllUwaziTemplate() throws 
    func deleteUwaziTemplate(templateId: String) throws
    func deleteUwaziTemplate(id: Int) -> Result<Bool,Error>  
}
