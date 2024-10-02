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
    static let descriptionFolderName = "description.txt"
    static let filesRequestBody =  """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <d:propfind xmlns:d=\"DAV:\" xmlns:oc=\"http://owncloud.org/ns\" xmlns:nc=\"http://nextcloud.org/ns\">
            <d:prop></d:prop>
        </d:propfind>
        """
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
