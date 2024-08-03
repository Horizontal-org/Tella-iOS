//
//  NextcloudConstants.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextcloudConstants {
    static let forbiddenCharacters = ["/", "\\", ":", "\"", "|", "?", "*", "<", ">"]
    static let descriptionFolderName = "Readme.md"
}

extension String {
    
    func removeForbiddenCharacters() -> String {
        
        var fileName = self
        for character in NextcloudConstants.forbiddenCharacters {
            fileName = fileName.replacingOccurrences(of: character, with: "")
        }
        return fileName
    }
    
}
