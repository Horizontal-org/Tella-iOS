//
//  SecTrust+Extension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/6/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Security
import Foundation

extension SecTrust {
    
    /// DER data of the peer's certificate.
    var certificateData: Data? {
        guard let certificate = SecTrustGetCertificateAtIndex(self, 0) else {
            return nil
        }
        return SecCertificateCopyData(certificate) as Data
    }
    
    var certificateHash: String? {
        certificateData?.sha256()
    }
}
