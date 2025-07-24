//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class ProgressFileItemViewModel: ObservableObject {
    
    let vaultFile: VaultFileDB
    
    @Published var transferSummary: String
    @Published var transferProgress: Double?
    @Published var p2pFileStatus: P2PFileStatus?
    
    init(vaultFile: VaultFileDB,
         transferSummary: String,
         transferProgress: Double? = nil,
         p2pFileStatus: P2PFileStatus? = nil) {
        self.vaultFile = vaultFile
        self.transferSummary = transferSummary
        self.transferProgress = transferProgress
        self.p2pFileStatus = p2pFileStatus
    }
}

extension P2PFileStatus {
    var statusIcon: String? {
        switch self {
        case .transferring:
            return "home.progress-circle"
        case .finished:
            return "report.submitted"
        default:
            return nil
        }
    }
}
