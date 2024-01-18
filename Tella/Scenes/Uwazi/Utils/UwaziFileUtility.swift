//
//  UwaziFileUtility.swift
//  Tella
//
//  Created by Gustavo on 02/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


struct UwaziFileUtility {
    var files: Set<VaultFileDB>
    var mainAppModel: MainAppModel?
    
    func getFilesInfo() -> [UwaziAttachment] {
        return files.compactMap { file in
            if let fileData = self.mainAppModel?.vaultManager.loadFileData(fileName: file.id) {
                return UwaziAttachment(filename: file.name, data: fileData, fileExtension: file.fileExtension)
            } else {
                return nil
            }
        }
    }
    
    func extractFilesAsAttachments() ->[[String: Any]] {
        var attachments = [[String: Any]]()
        for file in files {
            let attachment = [
                "originalname": "\(file.name).\(file.fileExtension)",
                "filename": "\(file.name).\(file.fileExtension)",
                "type": "attachment",
                "mimetype": MIMEType.mime(for: file.fileExtension),
                "entity": "NEW_ENTITY"
            ] as [String: Any]
                    
            attachments.append(attachment)
        }
        
        return attachments
    }
    
}
