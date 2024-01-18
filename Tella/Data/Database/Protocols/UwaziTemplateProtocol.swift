//
//  UwaziTemplateProtocol.swift
//  Tella
//
//  Created by Robert Shrestha on 9/11/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

protocol UwaziTemplateProtocol {
    func createTemplateTableForUwazi()
    func getUwaziTemplate(serverId: Int) throws -> CollectedTemplate?
    func getUwaziTemplate(templateId: Int) throws -> CollectedTemplate?
    func getAllUwaziTemplate() throws -> [CollectedTemplate]
    func addUwaziTemplate(template: CollectedTemplate) throws -> CollectedTemplate?
    func deleteAllUwaziTemplate() throws 
    func deleteUwaziTemplate(templateId: String) throws
    func deleteUwaziTemplate(id: Int) throws
}
