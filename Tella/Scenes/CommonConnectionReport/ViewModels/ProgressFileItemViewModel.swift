//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class ProgressFileItemViewModel: ObservableObject {
    
    let vaultFile: VaultFileDB
    
    @Published var transferSummary: String
    @Published var transferProgress: Double?
    @Published var fileStatus: NearbySharingFileStatus?
    
    init(vaultFile: VaultFileDB,
         transferSummary: String,
         transferProgress: Double? = nil,
         fileStatus: NearbySharingFileStatus? = nil) {
        self.vaultFile = vaultFile
        self.transferSummary = transferSummary
        self.transferProgress = transferProgress
        self.fileStatus = fileStatus
    }
}

extension NearbySharingFileStatus {
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
