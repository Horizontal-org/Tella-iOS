//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class ProgressFileItemViewModel: ObservableObject {
    
    let vaultFile: VaultFileDB
    
    @Published var transferSummary: String
    @Published var transferProgress: Double?
    @Published var fileStatus: FileStatus?
    @Published var nearbySharingFileStatus: NearbySharingFileStatus?
    
    init(vaultFile: VaultFileDB,
         transferSummary: String,
         fileStatus: FileStatus? = nil,
         nearbySharingFileStatus: NearbySharingFileStatus? = nil) {
        self.vaultFile = vaultFile
        self.transferSummary = transferSummary
        self.fileStatus = fileStatus
        self.nearbySharingFileStatus = nearbySharingFileStatus
    }
}

extension NearbySharingFileStatus {
    var statusIcon: String? {
        switch self {
        case .saving:
            return "home.progress-circle"
        case .saved:
            return "report.submitted"
        default:
            return nil
        }
    }
}
