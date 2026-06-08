//
//  OSStatus+Security.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/6/2026.
//  Copyright © 2026 HORIZONTAL. All rights reserved.
//

import Foundation
import Security

extension OSStatus {

    var securityMessage: String {
        SecCopyErrorMessageString(self, nil) as String? ?? "\(self)"
    }
}
